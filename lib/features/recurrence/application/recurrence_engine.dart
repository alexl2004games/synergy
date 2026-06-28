import 'package:logging/logging.dart';
import 'package:rrule/rrule.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/tasks_dao.dart';
import '../../../core/database/tables.dart';
import 'package:drift/drift.dart' as drift;
final _log = Logger('RecurrenceEngine');
class RecurrenceEngine {
  RecurrenceEngine({required TasksDao tasksDao}) : _tasksDao = tasksDao;
  final TasksDao _tasksDao;
  static const _uuid = Uuid();
  Future<void> materialize({
    required Task templateTask,
    required DateTime startDate,
    required int days,
  }) async {
    if (templateTask.recurrenceRule == null ||
        templateTask.recurrenceRule!.isEmpty) {
      return;
    }
    _log.info(
      'Materializing template "${templateTask.title}" (id=${templateTask.id}) '
      'from $startDate for $days days',
    );
    try {
      final recurrenceRule = _normalizeRecurrenceRule(
        templateTask.recurrenceRule!,
      );
      final rrule = RecurrenceRule.fromString(recurrenceRule);
      final dtStartLocal = templateTask.startAt != null
          ? DateTime.fromMillisecondsSinceEpoch(templateTask.startAt!)
          : startDate;
      final utcDtStart = dtStartLocal.toUtc();
      final utcStartDate = startDate.toUtc();
      final endDate = startDate.add(Duration(days: days));
      final utcEndDate = endDate.toUtc();
      final allOccurrences = rrule.getInstances(start: utcDtStart);
      final occurrences = <DateTime>[];
      for (final occurrence in allOccurrences) {
        if (occurrence.isAfter(utcEndDate)) {
          break;
        }
        if (occurrence.isBefore(utcStartDate)) {
          continue;
        }
        occurrences.add(occurrence.toLocal());
        if (occurrences.length >= days * 2) {
          break;
        }
      }
      _log.info('  Found ${occurrences.length} occurrences');
      final instances = <TasksCompanion>[];
      for (final occurrence in occurrences) {
        if (occurrence.isBefore(startDate)) {
          _log.fine('  Skipping occurrence before startDate: $occurrence');
          continue;
        }
        final duration = _getTaskDuration(templateTask);
        final endAt = occurrence.add(duration);
        int? instanceDeadlineAt;
        if (templateTask.deadlineAt != null && templateTask.startAt != null) {
          final startDateTime =
              DateTime.fromMillisecondsSinceEpoch(templateTask.startAt!);
          final deadlineDateTime =
              DateTime.fromMillisecondsSinceEpoch(templateTask.deadlineAt!);
          final deadlineOffset = deadlineDateTime.difference(startDateTime);
          instanceDeadlineAt =
              occurrence.add(deadlineOffset).millisecondsSinceEpoch;
        } else {
          instanceDeadlineAt = templateTask.deadlineAt;
        }
        final instance = TasksCompanion(
          id: drift.Value(_uuid.v4()),
          title: drift.Value(templateTask.title),
          notes: drift.Value(templateTask.notes),
          parentTaskId: drift.Value(templateTask.id),
          recurrenceRule: const drift.Value(null),
          isExceptionOfRule: const drift.Value(false),
          exceptionOriginalId: const drift.Value(null),
          startAt: drift.Value(occurrence.millisecondsSinceEpoch),
          endAt: templateTask.endAt != null
              ? drift.Value(endAt.millisecondsSinceEpoch)
              : const drift.Value(null),
          deadlineAt: drift.Value(instanceDeadlineAt),
          isAllDay: drift.Value(templateTask.isAllDay),
          isPinned: drift.Value(templateTask.isPinned),
          estMin: drift.Value(templateTask.estMin),
          actualMin: const drift.Value(null),
          status: const drift.Value(TaskStatus.pending),
          priority: drift.Value(templateTask.priority),
          aiConfidence: drift.Value(templateTask.aiConfidence),
          createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
          updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
          completedAt: const drift.Value(null),
        );
        instances.add(instance);
      }
      _log.info('  Creating ${instances.length} instances');
      for (final instance in instances) {
        await _tasksDao.save(instance);
      }
    } on FormatException catch (e) {
      _log.warning(
        'Invalid RRULE format for task ${templateTask.id}: ${templateTask.recurrenceRule}',
        e,
      );
    } on Object catch (e) {
      _log.severe('Unexpected error materializing recurrence: $e');
    }
  }
  Future<void> deleteInstance(Task instance) async {
    final updated = instance.copyWith(
      status: TaskStatus.cancelled,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _tasksDao.updateTask(updated);
  }
  Future<void> deleteAllFuture(Task instance) async {
    if (instance.parentTaskId == null) {
      return;
    }
    final parentId = instance.parentTaskId;
    final allInstances = await _tasksDao.getTasksByParentId(parentId!);
    for (final future in allInstances) {
      if (future.startAt != null &&
          DateTime.fromMillisecondsSinceEpoch(future.startAt!).isAfter(
            DateTime.fromMillisecondsSinceEpoch(instance.startAt ?? 0).subtract(
              const Duration(days: 1),
            ),
          )) {
        final updated = future.copyWith(
          status: TaskStatus.cancelled,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _tasksDao.updateTask(updated);
      }
    }
  }
  Future<void> deleteRule(Task templateTask) async {
    await deleteSeries(templateTask);
  }
  Future<void> deleteSeries(Task task) async {
    try {
      final templateId = task.parentTaskId ?? task.id;
      final template = await _tasksDao.getById(templateId);
      if (template == null) {
        return;
      }
      final updatedTemplate = template.copyWith(
        status: TaskStatus.cancelled,
        recurrenceRule: const drift.Value<String?>(null),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _tasksDao.updateTask(updatedTemplate);
      final instances = await _tasksDao.getTasksByParentId(templateId);
      for (final instance in instances) {
        final updated = instance.copyWith(
          status: TaskStatus.cancelled,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _tasksDao.updateTask(updated);
      }
    } on Object catch (e) {
      _log.severe('Unexpected error in deleteSeries: $e');
    }
  }
  Future<void> deleteAllExceptInstance(Task instance) async {
    try {
      final templateId = instance.parentTaskId ?? instance.id;
      final template = await _tasksDao.getById(templateId);
      if (template == null) {
        return;
      }
      if (instance.parentTaskId != null) {
        await _tasksDao.updateTask(
          template.copyWith(
            status: TaskStatus.cancelled,
            recurrenceRule: const drift.Value<String?>(null),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      } else {
        await _tasksDao.updateTask(
          template.copyWith(
            recurrenceRule: const drift.Value<String?>(null),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
      final siblings = await _tasksDao.getTasksByParentId(templateId);
      for (final sibling in siblings) {
        if (sibling.id == instance.id) {
          continue;
        }
        final updated = sibling.copyWith(
          status: TaskStatus.cancelled,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _tasksDao.updateTask(updated);
      }
    } on Object catch (e) {
      _log.severe('Unexpected error in deleteAllExceptInstance: $e');
    }
  }
  Duration _getTaskDuration(Task task) {
    if (task.startAt != null &&
        task.endAt != null &&
        task.endAt! > task.startAt!) {
      return Duration(milliseconds: task.endAt! - task.startAt!);
    }
    return Duration(minutes: task.estMin);
  }
  String _normalizeRecurrenceRule(String recurrenceRule) {
    final trimmed = recurrenceRule.trim();
    if (trimmed.startsWith('RRULE:')) {
      return trimmed;
    }
    return 'RRULE:$trimmed';
  }
}

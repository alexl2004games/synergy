import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../adaptation/application/adaptation_calculator.dart';
import '../domain/task.dart';
import '../../scheduling/application/task_scheduling_refresh_trigger.dart';
import '../data/drift_checklist_repository.dart';
import '../data/drift_reminder_repository.dart';
import '../data/drift_task_repository.dart';
import '../data/drift_task_tag_repository.dart';
import '../domain/checklist_repository.dart';
import '../domain/task_reminder_repository.dart';
import '../domain/task_repository.dart';
import '../domain/task_tag_repository.dart';
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final adaptationCalculator = ref.watch(adaptationCalculatorProvider);
  final trigger = ref.watch(taskSchedulingRefreshTriggerProvider);
  return _TaskRepositoryWithRefresh(
    delegate: DriftTaskRepository(db.tasksDao, adaptationCalculator),
    trigger: trigger,
  );
});
final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftChecklistRepository(db.checklistDao);
});
final taskTagRepositoryProvider = Provider<TaskTagRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftTaskTagRepository(db.taskTagsDao);
});
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftReminderRepository(db.taskRemindersDao);
});
class _TaskRepositoryWithRefresh implements TaskRepository {
  _TaskRepositoryWithRefresh({
    required TaskRepository delegate,
    required TaskSchedulingRefreshTrigger trigger,
  })  : _delegate = delegate,
        _trigger = trigger;
  final TaskRepository _delegate;
  final TaskSchedulingRefreshTrigger _trigger;
  @override
  Future<void> batchUpdate(List<Task> tasks) async {
    await _delegate.batchUpdate(tasks);
    _trigger.schedule();
  }
  @override
  Future<void> delete(String id) async {
    await _delegate.delete(id);
    _trigger.schedule();
  }
  @override
  Future<Task?> getById(String id) => _delegate.getById(id);
  @override
  Future<void> save(Task task) async {
    await _delegate.save(task);
    _trigger.schedule();
  }
  @override
  Future<void> update(Task task) async {
    await _delegate.update(task);
    _trigger.schedule();
  }
  @override
  Stream<List<Task>> watchByDay(DateTime day) => _delegate.watchByDay(day);
  @override
  Stream<List<Task>> watchInbox() => _delegate.watchInbox();
  @override
  Stream<List<Task>> watchOverdue() => _delegate.watchOverdue();
  @override
  Stream<List<Task>> watchToday() => _delegate.watchToday();
  @override
  Stream<List<Task>> watchUpcoming({int daysAhead = 7}) =>
      _delegate.watchUpcoming(daysAhead: daysAhead);
}

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../tables.dart';
import '../app_database.dart';
part 'tasks_dao.g.dart';
@DriftAccessor(tables: [Tasks, TaskTags, TaskReminders, TaskChecklistItems])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);
  final _uuid = const Uuid();
  Future<List<Task>> getAll() => select(tasks).get();
  Future<List<Task>> getAllTasks() => getAll();
  Stream<List<Task>> watchAll() {
    final query = select(tasks)
      ..where((t) =>
          t.recurrenceRule.isNull() &
          t.status.isIn([
            'pending',
            'inProgress',
            'overdue',
            'completed',
          ]),)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }
  Stream<List<Task>> watchAllTasks() => watchAll();
  Stream<List<Task>> watchInbox() {
    final query = select(tasks)
      ..where((t) =>
          t.startAt.isNull() &
          t.status.equals('pending') &
          t.recurrenceRule.isNull(),)
      ..where((t) => t.deadlineAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }
  Stream<List<Task>> watchInboxTasks() => watchInbox();
  Stream<List<Task>> watchToday() {
    final now = DateTime.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59)
        .millisecondsSinceEpoch;
    final query = select(tasks)
      ..where(
        (t) =>
            t.recurrenceRule.isNull() &
            (
              t.startAt.isBetweenValues(startOfDay, endOfDay) |
              t.deadlineAt.isBetweenValues(startOfDay, endOfDay) |
              (t.status.isIn(['pending', 'inProgress', 'overdue']) &
                  ((t.startAt.isNotNull() & t.startAt.isSmallerThanValue(startOfDay)) |
                   (t.deadlineAt.isNotNull() & t.deadlineAt.isSmallerThanValue(startOfDay)))) |
              (t.status.isIn(['pending', 'inProgress', 'overdue']) &
                  t.startAt.isNull() &
                  t.deadlineAt.isNotNull() &
                  t.deadlineAt.isBiggerOrEqualValue(startOfDay)) |
              (t.status.equals('completed') &
                  t.completedAt.isNotNull() &
                  t.completedAt.isBetweenValues(startOfDay, endOfDay))
            ),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }
  Stream<List<Task>> watchTodayTasks() => watchToday();
  Stream<List<Task>> watchUpcoming([int daysAhead = 7]) {
    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final end = DateTime(now.year, now.month, now.day)
        .add(Duration(days: daysAhead + 1));
    final query = select(tasks)
      ..where(
        (t) =>
            t.recurrenceRule.isNull() &
            t.status.isIn(['pending', 'inProgress', 'overdue']) &
            (
              t.startAt.isBetweenValues(
                start.millisecondsSinceEpoch,
                end.millisecondsSinceEpoch - 1,
              ) |
              t.deadlineAt.isBetweenValues(
                start.millisecondsSinceEpoch,
                end.millisecondsSinceEpoch - 1,
              )
            ),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.startAt)]);
    return query.watch();
  }
  Stream<List<Task>> watchUpcomingTasks() => watchUpcoming();
  Stream<List<Task>> watchByDay(DateTime date) {
    final today = DateTime.now();
    final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
    if (isToday) {
      return watchToday();
    }
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    final query = select(tasks)
      ..where(
        (t) =>
            t.recurrenceRule.isNull() &
            (t.status.isIn(['pending', 'inProgress', 'overdue', 'completed'])) &
            (
              t.startAt.isBetweenValues(startOfDay, endOfDay) |
              t.deadlineAt.isBetweenValues(startOfDay, endOfDay) |
              (t.status.equals('completed') &
                  t.completedAt.isNotNull() &
                  t.completedAt.isBetweenValues(startOfDay, endOfDay))
            ),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.startAt)]);
    return query.watch();
  }
  Stream<List<Task>> watchOverdue() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final query = select(tasks)
      ..where(
        (t) =>
            t.recurrenceRule.isNull() &
            (t.status.isIn(['pending', 'inProgress'])) &
            ((t.deadlineAt.isNotNull() & t.deadlineAt.isSmallerThanValue(now)) |
                (t.deadlineAt.isNull() &
                    t.startAt.isNotNull() &
                    t.startAt.isSmallerThanValue(now))),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.deadlineAt)]);
    return query.watch();
  }
  Future<Task?> getById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
  Future<Task?> getTaskById(String id) => getById(id);
  Future<int> save(TasksCompanion task) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(tasks).insertOnConflictUpdate(
      task.copyWith(
        id: Value(task.id.present ? task.id.value : _uuid.v4()),
        status: Value(
          task.status.present ? task.status.value : TaskStatus.pending,
        ),
        priority: Value(
          task.priority.present ? task.priority.value : TaskPriority.medium,
        ),
        isAllDay: Value(task.isAllDay.present && task.isAllDay.value),
        isPinned: Value(task.isPinned.present && task.isPinned.value),
        estMin: Value(task.estMin.present ? task.estMin.value : 30),
        aiConfidence: Value(
          task.aiConfidence.present ? task.aiConfidence.value : 1.0,
        ),
        isExceptionOfRule: Value(
          task.isExceptionOfRule.present && task.isExceptionOfRule.value,
        ),
        createdAt: Value(task.createdAt.present ? task.createdAt.value : now),
        updatedAt: Value(task.updatedAt.present ? task.updatedAt.value : now),
      ),
    );
  }
  Future<int> createTask(TasksCompanion task) => save(task);
  Future<bool> updateTask(Task task) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return update(tasks).replace(task.copyWith(updatedAt: now));
  }
  Future<List<Task>> getRecentCompletedWithActualMin(int limit) {
    final query = select(tasks)
      ..where(
        (task) =>
            task.status.equalsValue(TaskStatus.completed) &
            task.actualMin.isNotNull(),
      )
      ..orderBy([(task) => OrderingTerm.desc(task.completedAt)])
      ..limit(limit);
    return query.get();
  }
  Future<List<Task>> getCompletedTasksBetween(int startMs, int endMs) {
    final query = select(tasks)
      ..where(
        (task) =>
            task.status.equalsValue(TaskStatus.completed) &
            task.completedAt.isBetweenValues(startMs, endMs),
      );
    return query.get();
  }
  Future<void> batchUpdate(Iterable<Task> items) async {
    await transaction(() async {
      for (final item in items) {
        await updateTask(item);
      }
    });
  }
  Future<int> deleteTask(String id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }
  Future<List<TaskReminder>> getPendingReminders() {
    return (select(taskReminders)..where((r) => r.isSent.equals(false))).get();
  }
  Future<int> markReminderSent(String id) {
    return (update(taskReminders)..where((r) => r.id.equals(id))).write(
      const TaskRemindersCompanion(isSent: Value(true)),
    );
  }
  Future<List<Task>> getTasksByParentId(String parentTaskId) {
    return (select(tasks)..where((t) => t.parentTaskId.equals(parentTaskId)))
        .get();
  }
  Future<List<Task>> getRecurrenceTemplates() {
    final query = select(tasks)
      ..where(
        (t) =>
            t.recurrenceRule.isNotNull() &
            t.parentTaskId.isNull() &
            t.status.isNotIn(['completed', 'cancelled']),
      );
    return query.get();
  }
}

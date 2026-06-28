import '../../../core/database/app_database.dart' as app_db;
import '../../../core/database/tables.dart' as db;
import '../../../core/database/daos/tasks_dao.dart';
import '../../adaptation/application/adaptation_calculator.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';
class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(this._tasksDao, this._adaptationCalculator);
  final TasksDao _tasksDao;
  final AdaptationCalculator _adaptationCalculator;
  @override
  Stream<List<Task>> watchToday() {
    return _tasksDao.watchToday().map(_mapTasks);
  }
  @override
  Stream<List<Task>> watchInbox() {
    return _tasksDao.watchInbox().map(_mapTasks);
  }
  @override
  Stream<List<Task>> watchUpcoming({int daysAhead = 7}) {
    return _tasksDao.watchUpcoming(daysAhead).map(_mapTasks);
  }
  @override
  Stream<List<Task>> watchByDay(DateTime day) {
    return _tasksDao.watchByDay(day).map(_mapTasks);
  }
  @override
  Stream<List<Task>> watchOverdue() {
    return _tasksDao.watchOverdue().map(_mapTasks);
  }
  @override
  Future<Task?> getById(String id) async {
    final row = await _tasksDao.getById(id);
    return row?.toDomain();
  }
  @override
  Future<void> save(Task task) async {
    await _tasksDao.save(task.toDrift().toCompanion(false));
  }
  @override
  Future<void> update(Task task) async {
    await _tasksDao.updateTask(task.toDrift());
    if (task.status == TaskStatus.completed && task.actualMin != null) {
      await _adaptationCalculator.recalculateCorrectionFactor();
    }
  }
  @override
  Future<void> delete(String id) async {
    await _tasksDao.deleteTask(id);
  }
  @override
  Future<void> batchUpdate(List<Task> tasks) async {
    await _tasksDao.batchUpdate(tasks.map((task) => task.toDrift()));
  }
  List<Task> _mapTasks(List<app_db.Task> rows) {
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }
}
extension DriftTaskMapper on app_db.Task {
  Task toDomain() {
    return Task(
      id: id,
      title: title,
      notes: notes,
      deadlineAt: deadlineAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(deadlineAt!),
      startAt: startAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(startAt!),
      endAt: endAt == null ? null : DateTime.fromMillisecondsSinceEpoch(endAt!),
      isAllDay: isAllDay,
      isPinned: isPinned,
      estMin: estMin,
      actualMin: actualMin,
      status: switch (status) {
        db.TaskStatus.pending => TaskStatus.pending,
        db.TaskStatus.inProgress => TaskStatus.inProgress,
        db.TaskStatus.completed => TaskStatus.completed,
        db.TaskStatus.overdue => TaskStatus.overdue,
        db.TaskStatus.cancelled => TaskStatus.cancelled,
      },
      priority: switch (priority) {
        db.TaskPriority.low => TaskPriority.low,
        db.TaskPriority.medium => TaskPriority.medium,
        db.TaskPriority.high => TaskPriority.high,
      },
      aiConfidence: aiConfidence,
      parentTaskId: parentTaskId,
      recurrenceRule: recurrenceRule,
      isExceptionOfRule: isExceptionOfRule,
      exceptionOriginalId: exceptionOriginalId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      completedAt: completedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(completedAt!),
    );
  }
}
extension TaskDriftMapper on Task {
  app_db.Task toDrift() {
    return app_db.Task(
      id: id,
      title: title,
      notes: notes,
      deadlineAt: deadlineAt?.millisecondsSinceEpoch,
      startAt: startAt?.millisecondsSinceEpoch,
      endAt: endAt?.millisecondsSinceEpoch,
      isAllDay: isAllDay,
      isPinned: isPinned,
      estMin: estMin,
      actualMin: actualMin,
      status: switch (status) {
        TaskStatus.pending => db.TaskStatus.pending,
        TaskStatus.inProgress => db.TaskStatus.inProgress,
        TaskStatus.completed => db.TaskStatus.completed,
        TaskStatus.overdue => db.TaskStatus.overdue,
        TaskStatus.cancelled => db.TaskStatus.cancelled,
      },
      priority: switch (priority) {
        TaskPriority.low => db.TaskPriority.low,
        TaskPriority.medium => db.TaskPriority.medium,
        TaskPriority.high => db.TaskPriority.high,
      },
      aiConfidence: aiConfidence,
      parentTaskId: parentTaskId,
      recurrenceRule: recurrenceRule,
      isExceptionOfRule: isExceptionOfRule,
      exceptionOriginalId: exceptionOriginalId,
      createdAt: createdAt.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
      completedAt: completedAt?.millisecondsSinceEpoch,
    );
  }
}

import '../../../core/database/app_database.dart' as app_db;
import '../../../core/database/daos/task_reminders_dao.dart';
import '../domain/task_reminder.dart';
import '../domain/task_reminder_repository.dart';
class DriftReminderRepository implements ReminderRepository {
  DriftReminderRepository(this._taskRemindersDao);
  final TaskRemindersDao _taskRemindersDao;
  @override
  Future<List<TaskReminder>> getByTaskId(String taskId) async {
    final rows = await _taskRemindersDao.getByTaskId(taskId);
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }
  @override
  Stream<List<TaskReminder>> watchByTaskId(String taskId) {
    return _taskRemindersDao.watchByTaskId(taskId).map(
          (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
        );
  }
  @override
  Future<List<TaskReminder>> getPendingReminders() async {
    final rows = await _taskRemindersDao.getPendingReminders();
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }
  @override
  Future<TaskReminder?> getById(String id) async {
    final row = await _taskRemindersDao.getById(id);
    return row?.toDomain();
  }
  @override
  Future<void> save(TaskReminder reminder) async {
    await _taskRemindersDao.save(reminder.toDrift().toCompanion(false));
  }
  @override
  Future<void> update(TaskReminder reminder) async {
    await _taskRemindersDao.updateReminder(reminder.toDrift());
  }
  @override
  Future<void> markAsSent(String id) async {
    await _taskRemindersDao.markReminderSent(id);
  }
  @override
  Future<void> delete(String id) async {
    await _taskRemindersDao.deleteReminder(id);
  }
}
extension DriftTaskReminderMapper on app_db.TaskReminder {
  TaskReminder toDomain() {
    return TaskReminder(
      id: id,
      taskId: taskId,
      remindAt: DateTime.fromMillisecondsSinceEpoch(remindAt),
      isSent: isSent,
    );
  }
}
extension TaskReminderDriftMapper on TaskReminder {
  app_db.TaskReminder toDrift() {
    return app_db.TaskReminder(
      id: id,
      taskId: taskId,
      remindAt: remindAt.millisecondsSinceEpoch,
      isSent: isSent,
    );
  }
}

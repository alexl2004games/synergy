import 'task_reminder.dart';
abstract class ReminderRepository {
  Future<List<TaskReminder>> getByTaskId(String taskId);
  Stream<List<TaskReminder>> watchByTaskId(String taskId);
  Future<List<TaskReminder>> getPendingReminders();
  Future<TaskReminder?> getById(String id);
  Future<void> save(TaskReminder reminder);
  Future<void> update(TaskReminder reminder);
  Future<void> markAsSent(String id);
  Future<void> delete(String id);
}

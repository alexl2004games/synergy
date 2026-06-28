part of 'task_reminders_dao.dart';
// ignore_for_file: type=lint
mixin _$TaskRemindersDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $TaskRemindersTable get taskReminders => attachedDatabase.taskReminders;
  TaskRemindersDaoManager get managers => TaskRemindersDaoManager(this);
}
class TaskRemindersDaoManager {
  final _$TaskRemindersDaoMixin _db;
  TaskRemindersDaoManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$TaskRemindersTableTableManager get taskReminders =>
      $$TaskRemindersTableTableManager(_db.attachedDatabase, _db.taskReminders);
}

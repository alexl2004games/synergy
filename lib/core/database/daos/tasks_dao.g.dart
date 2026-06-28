part of 'tasks_dao.dart';
// ignore_for_file: type=lint
mixin _$TasksDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $TaskTagsTable get taskTags => attachedDatabase.taskTags;
  $TaskRemindersTable get taskReminders => attachedDatabase.taskReminders;
  $TaskChecklistItemsTable get taskChecklistItems =>
      attachedDatabase.taskChecklistItems;
  TasksDaoManager get managers => TasksDaoManager(this);
}
class TasksDaoManager {
  final _$TasksDaoMixin _db;
  TasksDaoManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$TaskTagsTableTableManager get taskTags =>
      $$TaskTagsTableTableManager(_db.attachedDatabase, _db.taskTags);
  $$TaskRemindersTableTableManager get taskReminders =>
      $$TaskRemindersTableTableManager(_db.attachedDatabase, _db.taskReminders);
  $$TaskChecklistItemsTableTableManager get taskChecklistItems =>
      $$TaskChecklistItemsTableTableManager(
          _db.attachedDatabase, _db.taskChecklistItems);
}

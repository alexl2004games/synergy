part of 'task_tags_dao.dart';
// ignore_for_file: type=lint
mixin _$TaskTagsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $TaskTagsTable get taskTags => attachedDatabase.taskTags;
  TaskTagsDaoManager get managers => TaskTagsDaoManager(this);
}
class TaskTagsDaoManager {
  final _$TaskTagsDaoMixin _db;
  TaskTagsDaoManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$TaskTagsTableTableManager get taskTags =>
      $$TaskTagsTableTableManager(_db.attachedDatabase, _db.taskTags);
}

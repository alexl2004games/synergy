part of 'checklist_dao.dart';
// ignore_for_file: type=lint
mixin _$ChecklistDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $TaskChecklistItemsTable get taskChecklistItems =>
      attachedDatabase.taskChecklistItems;
  ChecklistDaoManager get managers => ChecklistDaoManager(this);
}
class ChecklistDaoManager {
  final _$ChecklistDaoMixin _db;
  ChecklistDaoManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$TaskChecklistItemsTableTableManager get taskChecklistItems =>
      $$TaskChecklistItemsTableTableManager(
          _db.attachedDatabase, _db.taskChecklistItems);
}

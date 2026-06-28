import '../../../core/database/app_database.dart' as app_db;
import '../../../core/database/daos/checklist_dao.dart';
import '../domain/checklist_repository.dart';
import '../domain/task_checklist_item.dart';
class DriftChecklistRepository implements ChecklistRepository {
  DriftChecklistRepository(this._checklistDao);
  final ChecklistDao _checklistDao;
  @override
  Future<List<TaskChecklistItem>> getByTaskId(String taskId) async {
    final rows = await _checklistDao.getByTaskId(taskId);
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }
  @override
  Stream<List<TaskChecklistItem>> watchByTaskId(String taskId) {
    return _checklistDao.watchByTaskId(taskId).map(
          (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
        );
  }
  @override
  Future<TaskChecklistItem?> getById(String id) async {
    final row = await _checklistDao.getById(id);
    return row?.toDomain();
  }
  @override
  Future<void> save(TaskChecklistItem item) async {
    await _checklistDao.save(item.toDrift().toCompanion(false));
  }
  @override
  Future<void> update(TaskChecklistItem item) async {
    await _checklistDao.updateItem(item.toDrift());
  }
  @override
  Future<void> delete(String id) async {
    await _checklistDao.deleteItem(id);
  }
  @override
  Future<void> reorder(String taskId, List<String> itemIds) async {
    await _checklistDao.reorder(taskId, itemIds);
  }
}
extension DriftChecklistItemMapper on app_db.TaskChecklistItem {
  TaskChecklistItem toDomain() {
    return TaskChecklistItem(
      id: id,
      taskId: taskId,
      title: title,
      isDone: isDone,
      orderIndex: orderIndex,
    );
  }
}
extension ChecklistItemDriftMapper on TaskChecklistItem {
  app_db.TaskChecklistItem toDrift() {
    return app_db.TaskChecklistItem(
      id: id,
      taskId: taskId,
      title: title,
      isDone: isDone,
      orderIndex: orderIndex,
    );
  }
}

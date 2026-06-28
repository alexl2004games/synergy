import '../../../core/database/app_database.dart' as app_db;
import '../../../core/database/daos/task_tags_dao.dart';
import '../domain/task_tag.dart';
import '../domain/task_tag_repository.dart';
class DriftTaskTagRepository implements TaskTagRepository {
  DriftTaskTagRepository(this._taskTagsDao);
  final TaskTagsDao _taskTagsDao;
  @override
  Future<List<TaskTag>> getByTaskId(String taskId) async {
    final rows = await _taskTagsDao.getByTaskId(taskId);
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }
  @override
  Stream<List<TaskTag>> watchByTaskId(String taskId) {
    return _taskTagsDao.watchByTaskId(taskId).map(
          (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
        );
  }
  @override
  Future<TaskTag?> getById(String id) async {
    final row = await _taskTagsDao.getById(id);
    return row?.toDomain();
  }
  @override
  Future<void> save(TaskTag tag) async {
    await _taskTagsDao.save(tag.toDrift().toCompanion(false));
  }
  @override
  Future<void> update(TaskTag tag) async {
    await _taskTagsDao.updateTag(tag.toDrift());
  }
  @override
  Future<void> delete(String id) async {
    await _taskTagsDao.deleteTag(id);
  }
}
extension DriftTaskTagMapper on app_db.TaskTag {
  TaskTag toDomain() {
    return TaskTag(
      id: id,
      taskId: taskId,
      tagName: tagName,
      isPrimary: isPrimary,
    );
  }
}
extension TaskTagDriftMapper on TaskTag {
  app_db.TaskTag toDrift() {
    return app_db.TaskTag(
      id: id,
      taskId: taskId,
      tagName: tagName,
      isPrimary: isPrimary,
    );
  }
}

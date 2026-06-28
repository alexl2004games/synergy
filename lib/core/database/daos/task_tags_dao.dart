import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables.dart';
part 'task_tags_dao.g.dart';
@DriftAccessor(tables: [TaskTags])
class TaskTagsDao extends DatabaseAccessor<AppDatabase>
    with _$TaskTagsDaoMixin {
  TaskTagsDao(super.db);
  final _uuid = const Uuid();
  Future<List<TaskTag>> getByTaskId(String taskId) {
    final query = select(taskTags)
      ..where((row) => row.taskId.equals(taskId))
      ..orderBy([(row) => OrderingTerm.asc(row.tagName)]);
    return query.get();
  }
  Stream<List<TaskTag>> watchAllTags() {
    return select(taskTags).watch();
  }
  Stream<List<TaskTag>> watchByTaskId(String taskId) {
    final query = select(taskTags)
      ..where((row) => row.taskId.equals(taskId))
      ..orderBy([(row) => OrderingTerm.asc(row.tagName)]);
    return query.watch();
  }
  Future<TaskTag?> getById(String id) {
    return (select(taskTags)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }
  Future<int> save(TaskTagsCompanion tag) {
    return into(taskTags).insertOnConflictUpdate(
      tag.copyWith(id: Value(tag.id.present ? tag.id.value : _uuid.v4())),
    );
  }
  Future<bool> updateTag(TaskTag tag) => update(taskTags).replace(tag);
  Future<int> deleteTag(String id) {
    return (delete(taskTags)..where((row) => row.id.equals(id))).go();
  }
}

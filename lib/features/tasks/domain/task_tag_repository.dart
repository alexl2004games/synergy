import 'task_tag.dart';
abstract class TaskTagRepository {
  Future<List<TaskTag>> getByTaskId(String taskId);
  Stream<List<TaskTag>> watchByTaskId(String taskId);
  Future<TaskTag?> getById(String id);
  Future<void> save(TaskTag tag);
  Future<void> update(TaskTag tag);
  Future<void> delete(String id);
}

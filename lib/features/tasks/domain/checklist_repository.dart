import 'task_checklist_item.dart';
abstract class ChecklistRepository {
  Future<List<TaskChecklistItem>> getByTaskId(String taskId);
  Stream<List<TaskChecklistItem>> watchByTaskId(String taskId);
  Future<TaskChecklistItem?> getById(String id);
  Future<void> save(TaskChecklistItem item);
  Future<void> update(TaskChecklistItem item);
  Future<void> delete(String id);
  Future<void> reorder(String taskId, List<String> itemIds);
}

import 'task.dart';
abstract class TaskRepository {
  Stream<List<Task>> watchToday();
  Stream<List<Task>> watchInbox();
  Stream<List<Task>> watchUpcoming({int daysAhead = 7});
  Stream<List<Task>> watchByDay(DateTime day);
  Stream<List<Task>> watchOverdue();
  Future<Task?> getById(String id);
  Future<void> save(Task task);
  Future<void> update(Task task);
  Future<void> delete(String id);
  Future<void> batchUpdate(List<Task> tasks);
}

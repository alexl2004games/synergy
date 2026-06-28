import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables.dart';
part 'task_reminders_dao.g.dart';
@DriftAccessor(tables: [TaskReminders])
class TaskRemindersDao extends DatabaseAccessor<AppDatabase>
    with _$TaskRemindersDaoMixin {
  TaskRemindersDao(super.db);
  final _uuid = const Uuid();
  Future<List<TaskReminder>> getByTaskId(String taskId) {
    final query = select(taskReminders)
      ..where((row) => row.taskId.equals(taskId))
      ..orderBy([(row) => OrderingTerm.asc(row.remindAt)]);
    return query.get();
  }
  Stream<List<TaskReminder>> watchByTaskId(String taskId) {
    final query = select(taskReminders)
      ..where((row) => row.taskId.equals(taskId))
      ..orderBy([(row) => OrderingTerm.asc(row.remindAt)]);
    return query.watch();
  }
  Future<TaskReminder?> getById(String id) {
    return (select(taskReminders)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }
  Future<int> save(TaskRemindersCompanion reminder) {
    return into(taskReminders).insertOnConflictUpdate(
      reminder.copyWith(
        id: Value(reminder.id.present ? reminder.id.value : _uuid.v4()),
      ),
    );
  }
  Future<List<TaskReminder>> getPendingReminders() {
    return (select(taskReminders)..where((row) => row.isSent.equals(false)))
        .get();
  }
  Future<bool> updateReminder(TaskReminder reminder) =>
      update(taskReminders).replace(reminder);
  Future<int> markReminderSent(String id) {
    return (update(taskReminders)..where((row) => row.id.equals(id))).write(
      const TaskRemindersCompanion(isSent: Value(true)),
    );
  }
  Future<int> deleteReminder(String id) {
    return (delete(taskReminders)..where((row) => row.id.equals(id))).go();
  }
}

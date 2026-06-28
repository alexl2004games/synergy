import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables.dart';
part 'checklist_dao.g.dart';
@DriftAccessor(tables: [TaskChecklistItems])
class ChecklistDao extends DatabaseAccessor<AppDatabase>
    with _$ChecklistDaoMixin {
  ChecklistDao(super.db);
  final _uuid = const Uuid();
  Future<List<TaskChecklistItem>> getByTaskId(String taskId) {
    final query = select(taskChecklistItems)
      ..where((row) => row.taskId.equals(taskId))
      ..orderBy([(row) => OrderingTerm.asc(row.orderIndex)]);
    return query.get();
  }
  Stream<List<TaskChecklistItem>> watchByTaskId(String taskId) {
    final query = select(taskChecklistItems)
      ..where((row) => row.taskId.equals(taskId))
      ..orderBy([(row) => OrderingTerm.asc(row.orderIndex)]);
    return query.watch();
  }
  Future<TaskChecklistItem?> getById(String id) {
    return (select(taskChecklistItems)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }
  Future<int> save(TaskChecklistItemsCompanion item) {
    return into(taskChecklistItems).insertOnConflictUpdate(
      item.copyWith(
        id: Value(item.id.present ? item.id.value : _uuid.v4()),
      ),
    );
  }
  Future<bool> updateItem(TaskChecklistItem item) {
    return update(taskChecklistItems).replace(item);
  }
  Future<int> deleteItem(String id) {
    return (delete(taskChecklistItems)..where((row) => row.id.equals(id))).go();
  }
  Future<void> reorder(String taskId, List<String> itemIds) async {
    await transaction(() async {
      for (var i = 0; i < itemIds.length; i += 1) {
        final itemId = itemIds[i];
        await (update(taskChecklistItems)
              ..where(
                (row) => row.id.equals(itemId) & row.taskId.equals(taskId),
              ))
            .write(TaskChecklistItemsCompanion(orderIndex: Value(i)));
      }
    });
  }
}

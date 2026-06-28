import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../tables.dart';
import '../app_database.dart';
part 'user_checkins_dao.g.dart';
@DriftAccessor(tables: [UserCheckins])
class CheckInsDao extends DatabaseAccessor<AppDatabase>
    with _$CheckInsDaoMixin {
  CheckInsDao(super.db);
  final _uuid = const Uuid();
  Future<List<UserCheckin>> getAll() {
    return select(userCheckins).get();
  }
  Future<List<UserCheckin>> getAllCheckins() => getAll();
  Stream<List<UserCheckin>> watchAll() {
    return select(userCheckins).watch();
  }
  Stream<List<UserCheckin>> watchAllCheckins() => watchAll();
  Future<UserCheckin?> getByDate(int date) {
    return (select(userCheckins)..where((c) => c.date.equals(date)))
        .getSingleOrNull();
  }
  Future<UserCheckin?> getCheckinForDate(int date) => getByDate(date);
  Future<List<UserCheckin>> getRecent(int limit) {
    final query = select(userCheckins)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    return query.get();
  }
  Future<int> save(UserCheckinsCompanion checkin) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return transaction(() async {
      final existingDate = checkin.date.present ? checkin.date.value : null;
      if (existingDate != null) {
        final existing = await getByDate(existingDate);
        if (existing != null) {
          await (update(userCheckins)
                ..where((row) => row.id.equals(existing.id)))
              .write(
            checkin.copyWith(
              id: Value(existing.id),
              createdAt: Value(existing.createdAt),
            ),
          );
          return 1;
        }
      }
      return into(userCheckins).insert(
        checkin.copyWith(
          id: Value(checkin.id.present ? checkin.id.value : _uuid.v4()),
          createdAt:
              Value(checkin.createdAt.present ? checkin.createdAt.value : now),
        ),
      );
    });
  }
  Future<int> insertCheckin(UserCheckinsCompanion checkin) => save(checkin);
}
typedef UserCheckinsDao = CheckInsDao;

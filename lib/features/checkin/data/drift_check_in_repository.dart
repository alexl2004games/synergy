import '../../../core/database/app_database.dart' as app_db;
import '../../../core/database/daos/user_checkins_dao.dart';
import '../domain/check_in_repository.dart';
import '../domain/user_checkin.dart';
class DriftCheckInRepository implements CheckInRepository {
  DriftCheckInRepository(this._checkInsDao);
  final CheckInsDao _checkInsDao;
  @override
  Future<List<UserCheckin>> getAll() async {
    final rows = await _checkInsDao.getAll();
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }
  @override
  Stream<List<UserCheckin>> watchAll() {
    return _checkInsDao.watchAll().map(
          (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
        );
  }
  @override
  Future<UserCheckin?> getByDate(DateTime date) async {
    final row = await _checkInsDao.getByDate(_toDateKey(date));
    return row?.toDomain();
  }
  @override
  Future<List<UserCheckin>> getRecent(int limit) async {
    final rows = await _checkInsDao.getRecent(limit);
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }
  @override
  Future<void> save(UserCheckin checkin) async {
    await _checkInsDao.save(checkin.toDrift().toCompanion(false));
  }
}
extension DriftCheckInMapper on app_db.UserCheckin {
  UserCheckin toDomain() {
    return UserCheckin(
      id: id,
      date: DateTime(
        _yearFromDate(date),
        _monthFromDate(date),
        _dayFromDate(date),
      ),
      moodScore: moodScore,
      productivity: productivity,
      energy: energy,
      note: note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }
}
extension CheckInDriftMapper on UserCheckin {
  app_db.UserCheckin toDrift() {
    return app_db.UserCheckin(
      id: id,
      date: _toDateKey(date),
      moodScore: moodScore,
      productivity: productivity,
      energy: energy,
      note: note,
      createdAt: createdAt.millisecondsSinceEpoch,
    );
  }
}
int _toDateKey(DateTime date) {
  return date.year * 10000 + date.month * 100 + date.day;
}
int _yearFromDate(int date) => date ~/ 10000;
int _monthFromDate(int date) => (date % 10000) ~/ 100;
int _dayFromDate(int date) => date % 100;

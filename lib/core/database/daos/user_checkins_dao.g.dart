part of 'user_checkins_dao.dart';
// ignore_for_file: type=lint
mixin _$CheckInsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserCheckinsTable get userCheckins => attachedDatabase.userCheckins;
  CheckInsDaoManager get managers => CheckInsDaoManager(this);
}
class CheckInsDaoManager {
  final _$CheckInsDaoMixin _db;
  CheckInsDaoManager(this._db);
  $$UserCheckinsTableTableManager get userCheckins =>
      $$UserCheckinsTableTableManager(_db.attachedDatabase, _db.userCheckins);
}

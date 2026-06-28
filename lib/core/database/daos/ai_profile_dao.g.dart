part of 'ai_profile_dao.dart';
// ignore_for_file: type=lint
mixin _$AiProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $AiProfileTable get aiProfile => attachedDatabase.aiProfile;
  AiProfileDaoManager get managers => AiProfileDaoManager(this);
}
class AiProfileDaoManager {
  final _$AiProfileDaoMixin _db;
  AiProfileDaoManager(this._db);
  $$AiProfileTableTableManager get aiProfile =>
      $$AiProfileTableTableManager(_db.attachedDatabase, _db.aiProfile);
}

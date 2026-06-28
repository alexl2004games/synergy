import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';
part 'ai_profile_dao.g.dart';
@DriftAccessor(tables: [AiProfile])
class AiProfileDao extends DatabaseAccessor<AppDatabase>
    with _$AiProfileDaoMixin {
  AiProfileDao(super.db);
  Future<AiProfileData?> get() async {
    return null;
  }
  Future<AiProfileData?> getProfile() => get();
  Stream<AiProfileData?> watch() {
    return Stream.value(null);
  }
  Stream<AiProfileData?> watchProfile() => watch();
  Future<void> updateProfile(AiProfileCompanion entry) async {
    return;
  }
}

import '../../database/app_database.dart' as app_db;
import '../../database/daos/ai_profile_dao.dart';
import '../../llm/domain/ai_profile.dart';
import '../domain/adaptation_repository.dart';
class DriftAdaptationRepository implements AdaptationRepository {
  DriftAdaptationRepository(this._aiProfileDao);
  final AiProfileDao _aiProfileDao;
  @override
  Future<AIProfile?> getProfile() async {
    final row = await _aiProfileDao.get();
    return row?.toDomain();
  }
  @override
  Stream<AIProfile?> watchProfile() {
    return _aiProfileDao.watch().map((row) => row?.toDomain());
  }
  @override
  Future<void> save(AIProfile profile) async {
    await _aiProfileDao.updateProfile(profile.toDrift().toCompanion(false));
  }
  @override
  Future<void> update(AIProfile profile) async {
    await _aiProfileDao.updateProfile(profile.toDrift().toCompanion(false));
  }
}
extension DriftAIProfileMapper on app_db.AiProfileData {
  AIProfile toDomain() {
    return AIProfile(
      correctionFactor: correctionFactor,
      avgMoodScore: avgMoodScore,
      peakHoursStart: peakHoursStart,
      peakHoursEnd: peakHoursEnd,
      totalCheckins: totalCheckins,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}
extension AIProfileDriftMapper on AIProfile {
  app_db.AiProfileData toDrift() {
    return app_db.AiProfileData(
      id: 'main',
      correctionFactor: correctionFactor,
      avgMoodScore: avgMoodScore,
      peakHoursStart: peakHoursStart,
      peakHoursEnd: peakHoursEnd,
      totalCheckins: totalCheckins,
      updatedAt: updatedAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

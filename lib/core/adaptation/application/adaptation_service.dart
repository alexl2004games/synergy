import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../providers/database_provider.dart';
import '../../database/app_database.dart';
import '../../database/daos/user_checkins_dao.dart';
import '../../database/daos/ai_profile_dao.dart';
final adaptationServiceProvider = Provider<AdaptationService>((ref) {
  final db = ref.watch(databaseProvider);
  return AdaptationService(db.userCheckinsDao, db.aiProfileDao);
});
class AdaptationService {
  AdaptationService(this._checkinsDao, this._profileDao);
  final UserCheckinsDao _checkinsDao;
  final AiProfileDao _profileDao;
  Future<void> submitCheckin({
    required int mood,
    required int productivity,
    required String note,
  }) async {
    final now = DateTime.now();
    final dateInt = now.year * 10000 + now.month * 100 + now.day;
    await _checkinsDao.insertCheckin(
      UserCheckinsCompanion(
        date: drift.Value(dateInt),
        moodScore: drift.Value(mood),
        productivity: drift.Value(productivity),
        note: drift.Value(note),
      ),
    );
    await _recalculateProfile();
  }
  Future<bool> hasCheckedInToday() async {
    final now = DateTime.now();
    final dateInt = now.year * 10000 + now.month * 100 + now.day;
    final checkin = await _checkinsDao.getCheckinForDate(dateInt);
    return checkin != null;
  }
  Future<void> _recalculateProfile() async {
    final allCheckins = await _checkinsDao.getAllCheckins();
    if (allCheckins.isEmpty) return;
    var sumMood = 0;
    var sumProd = 0;
    for (final c in allCheckins) {
      sumMood += c.moodScore;
      sumProd += c.productivity;
    }
    final avgMood = sumMood / allCheckins.length;
    final avgProd = sumProd / allCheckins.length;
    final newFactor = (avgProd + avgMood) / 6.0;
    final excellentCheckins =
        allCheckins.where((c) => c.productivity >= 4).toList();
    var peakStart = 9;
    var peakEnd = 12;
    if (excellentCheckins.isNotEmpty) {
      final sumHours = excellentCheckins
          .map((c) => DateTime.fromMillisecondsSinceEpoch(c.createdAt).hour)
          .reduce((a, b) => a + b);
      final avgHour = sumHours ~/ excellentCheckins.length;
      peakStart = avgHour;
      peakEnd = (avgHour + 3).clamp(0, 23);
    }
    await _profileDao.updateProfile(
      AiProfileCompanion(
        correctionFactor: drift.Value(newFactor),
        avgMoodScore: drift.Value(avgMood),
        totalCheckins: drift.Value(allCheckins.length),
        peakHoursStart: drift.Value(peakStart),
        peakHoursEnd: drift.Value(peakEnd),
      ),
    );
  }
}

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/daos/ai_profile_dao.dart';
import '../../../core/database/daos/tasks_dao.dart';
import '../../../core/database/daos/user_checkins_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart' as app_db;
import '../../../core/llm/domain/ai_profile.dart';
class AdaptationCalculator {
  AdaptationCalculator(this._tasksDao, this._checkInsDao, this._aiProfileDao);
  final TasksDao _tasksDao;
  final CheckInsDao _checkInsDao;
  final AiProfileDao _aiProfileDao;
  Future<double> recalculateCorrectionFactor() async {
    final tasks = await _tasksDao.getRecentCompletedWithActualMin(30);
    if (tasks.length < 5) {
      return 1.0;
    }
    final totalEstimated = tasks.fold<int>(0, (sum, task) => sum + task.estMin);
    if (totalEstimated <= 0) {
      return 1.0;
    }
    final totalActual =
        tasks.fold<int>(0, (sum, task) => sum + (task.actualMin ?? 0));
    final ratio = totalActual / totalEstimated;
    if (ratio < 0.5) {
      return 0.5;
    }
    if (ratio > 2.5) {
      return 2.5;
    }
    return ratio;
  }
  Future<({int start, int end})> recalculatePeakHours() async {
    final recentCheckins = await _checkInsDao.getRecent(30);
    final qualified = recentCheckins
        .where((checkin) => checkin.productivity >= 4 && checkin.energy >= 3)
        .toList();
    if (qualified.length < 5) {
      return (start: 9, end: 12);
    }
    final votes = <int, int>{};
    for (final checkin in qualified) {
      final year = checkin.date ~/ 10000;
      final month = (checkin.date % 10000) ~/ 100;
      final day = checkin.date % 100;
      final startMs = DateTime(year, month, day).millisecondsSinceEpoch;
      final endMs = DateTime(
        year,
        month,
        day,
        23,
        59,
        59,
      ).millisecondsSinceEpoch;
      final tasks = await _tasksDao.getCompletedTasksBetween(startMs, endMs);
      for (final task in tasks) {
        if (task.completedAt == null) continue;
        final weight = task.actualMin ?? task.estMin;
        if (weight <= 0) continue;
        final end = DateTime.fromMillisecondsSinceEpoch(task.completedAt!);
        final start = end.subtract(Duration(minutes: weight));
        var current = start;
        while (current.isBefore(end)) {
          final nextHour =
              DateTime(current.year, current.month, current.day, current.hour)
                  .add(const Duration(hours: 1));
          final limit = nextHour.isBefore(end) ? nextHour : end;
          final minutesInHour = limit.difference(current).inMinutes;
          if (minutesInHour > 0) {
            votes[current.hour] = (votes[current.hour] ?? 0) + minutesInHour;
          }
          current = limit;
        }
      }
    }
    if (votes.isEmpty) {
      for (final checkin in qualified) {
        final hour = DateTime.fromMillisecondsSinceEpoch(checkin.createdAt).hour;
        votes[hour] = (votes[hour] ?? 0) + 30;
      }
    }
    final orderedVotes = votes.entries.toList()
      ..sort((first, second) {
        final comparison = second.value.compareTo(first.value);
        if (comparison != 0) {
          return comparison;
        }
        return first.key.compareTo(second.key);
      });
    final peakStart = orderedVotes.isNotEmpty ? orderedVotes.first.key : 9;
    final peakEnd = peakStart + 3 > 23 ? 23 : peakStart + 3;
    return (start: peakStart, end: peakEnd);
  }
  Future<AIProfile> updateProfile() async {
    final correctionFactor = await recalculateCorrectionFactor();
    final peakHours = await recalculatePeakHours();
    final allCheckins = await _checkInsDao.getAll();
    final totalCheckins = allCheckins.length;
    final avgMoodScore = totalCheckins == 0
        ? 0.0
        : allCheckins.fold<double>(0, (sum, item) => sum + item.moodScore) /
            totalCheckins;
    final profile = AIProfile(
      correctionFactor: correctionFactor,
      avgMoodScore: avgMoodScore,
      peakHoursStart: peakHours.start,
      peakHoursEnd: peakHours.end,
      totalCheckins: totalCheckins,
      updatedAt: DateTime.now(),
    );
    await _aiProfileDao.updateProfile(
      app_db.AiProfileCompanion(
        correctionFactor: drift.Value(profile.correctionFactor),
        avgMoodScore: drift.Value(profile.avgMoodScore),
        peakHoursStart: drift.Value(profile.peakHoursStart),
        peakHoursEnd: drift.Value(profile.peakHoursEnd),
        totalCheckins: drift.Value(profile.totalCheckins),
      ),
    );
    return profile;
  }
}
final adaptationCalculatorProvider = Provider<AdaptationCalculator>((ref) {
  final db = ref.watch(databaseProvider);
  return AdaptationCalculator(db.tasksDao, db.checkInsDao, db.aiProfileDao);
});

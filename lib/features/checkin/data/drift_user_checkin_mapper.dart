import 'package:smart_diary/core/database/app_database.dart' as app_db;
import '../domain/user_checkin.dart';
extension DriftUserCheckinMapper on app_db.UserCheckin {
  UserCheckin toDomain() {
    final year = date ~/ 10000;
    final month = (date % 10000) ~/ 100;
    final day = date % 100;
    return UserCheckin(
      id: id,
      date: DateTime(year, month, day),
      moodScore: moodScore,
      productivity: productivity,
      energy: energy,
      note: note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }
}

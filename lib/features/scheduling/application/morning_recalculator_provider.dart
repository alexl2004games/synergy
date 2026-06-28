import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import 'morning_recalculator.dart';
final morningRecalculatorProvider = Provider<MorningRecalculator>((ref) {
  final db = ref.watch(databaseProvider);
  return MorningRecalculator(
    tasksDao: db.tasksDao,
    settingsDao: db.settingsDao,
    aiProfileDao: db.aiProfileDao,
  );
});

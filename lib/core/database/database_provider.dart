import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'daos/settings_dao.dart';
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
final settingsDaoProvider = Provider<SettingsDao>((ref) {
  return ref.watch(databaseProvider).settingsDao;
});

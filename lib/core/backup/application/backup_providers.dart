import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../domain/backup_snapshot.dart';
import '../domain/backup_settings_keys.dart';
import 'database_backup_service.dart';
import '../../sync/backup_service.dart';
final backupServiceProvider = Provider<DatabaseBackupService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = BackupService(
    db: db,
    settingsDao: db.settingsDao,
  );
  ref.onDispose(service.dispose);
  return service;
});
final latestBackupProvider = FutureProvider<BackupSnapshot?>((ref) {
  return ref.watch(backupServiceProvider).latestBackup();
});
final fresherBackupProvider = FutureProvider<BackupSnapshot?>((ref) {
  return ref.watch(backupServiceProvider).checkForNewerBackup();
});
final backupAutoEnabledProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getBoolValue(
    BackupSettingsKeys.autoBackupEnabled,
  );
  return value ?? false;
});

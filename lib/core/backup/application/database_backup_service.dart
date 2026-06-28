import 'dart:io';
import '../domain/backup_snapshot.dart';
abstract class DatabaseBackupService {
  Future<File> exportToJson();
  Future<void> importFromJson(File file);
  Future<void> autoBackup();
  Future<File?> findLatestBackupInICloud();
  Future<DateTime?> getLatestBackupDate();
  Future<BackupSnapshot?> latestBackup();
  Future<BackupSnapshot?> checkForNewerBackup();
  Future<BackupSnapshot> exportBackup();
  Future<BackupSnapshot> exportBackupToFile(File file);
  Future<String> getBackupDirectoryPath();
  Future<BackupSnapshot?> ensureDailyBackup();
  Future<void> importBackup(File file);
  Future<void> dispose();
}

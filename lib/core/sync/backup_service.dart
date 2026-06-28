import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../backup/application/database_backup_service.dart';
import '../backup/domain/backup_settings_keys.dart';
import '../backup/domain/backup_snapshot.dart';
import '../database/app_database.dart' as app_db;
import '../database/daos/settings_dao.dart';
import '../settings/domain/settings_keys.dart';
class BackupService implements DatabaseBackupService {
  BackupService({
    required app_db.AppDatabase db,
    required SettingsDao settingsDao,
    DateTime Function()? now,
  })  : _db = db,
        _settingsDao = settingsDao,
        _now = now ?? DateTime.now;
  final app_db.AppDatabase _db;
  final SettingsDao _settingsDao;
  final DateTime Function() _now;
  final Logger _log = Logger('BackupService');
  static const String _filePrefix = 'smart_diary_backup_';
  static const String _fileExtension = '.json';
  static const String _tablesKey = 'tables';
  static const String _metadataKey = 'metadata';
  static const String _appVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: '1.0.3+4');
  static const Duration _autoBackupCooldown = Duration(hours: 24);
  static const int _maxBackupsToKeep = 7;
  @override
  Future<File> exportToJson() async {
    try {
      final timestamp = _now();
      final file = File(
        p.join(
          await _backupDirectoryPath(),
          '$_filePrefix${_backupFileStamp(timestamp)}$_fileExtension',
        ),
      );
      await file.parent.create(recursive: true);
      final payload = await _buildExportPayload(timestamp);
      await file.writeAsString(jsonEncode(payload));
      await _settingsDao.setIntValue(
        BackupSettingsKeys.lastBackupTimestamp,
        timestamp.millisecondsSinceEpoch,
        trackLocalChange: false,
      );
      await _pruneOldBackups();
      return file;
    } on Object catch (error, stackTrace) {
      _log.severe('Failed to export backup', error, stackTrace);
      rethrow;
    }
  }
  @override
  Future<void> importFromJson(File file) async {
    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid backup format');
      }
      final metadata = _extractMetadata(decoded);
      final schemaVersion = _readSchemaVersion(metadata, decoded);
      if (schemaVersion != _db.schemaVersion) {
        throw FormatException(
          'Unsupported backup schema version: $schemaVersion',
        );
      }
      final tables = _extractTables(decoded);
      final importedDate = _readImportDate(metadata);
      await _db.transaction(() async {
        await _clearDatabase();
        await _importTables(tables);
        await _settingsDao.setIntValue(
          BackupSettingsKeys.lastBackupTimestamp,
          importedDate.millisecondsSinceEpoch,
          trackLocalChange: false,
        );
        await _settingsDao.setIntValue(
          SettingsKeys.lastLocalChange,
          _now().millisecondsSinceEpoch,
          trackLocalChange: false,
        );
      });
    } on Object catch (error, stackTrace) {
      _log.severe('Failed to import backup', error, stackTrace);
      rethrow;
    }
  }
  @override
  Future<void> autoBackup() async {
    try {
      final enabled = await _settingsDao
              .getBoolValue(BackupSettingsKeys.autoBackupEnabled) ??
          false;
      if (!enabled) {
        return;
      }
      final lastAutoBackupTimestamp = await _settingsDao.getIntValue(
        BackupSettingsKeys.lastAutoBackupTimestamp,
      );
      if (lastAutoBackupTimestamp != null) {
        final lastAutoBackup = DateTime.fromMillisecondsSinceEpoch(
          lastAutoBackupTimestamp,
        );
        if (_now().difference(lastAutoBackup) < _autoBackupCooldown) {
          return;
        }
      }
      final file = await exportToJson();
      await _settingsDao.setIntValue(
        BackupSettingsKeys.lastAutoBackupTimestamp,
        _now().millisecondsSinceEpoch,
        trackLocalChange: false,
      );
      await _pruneOldBackups(keepCurrent: file);
    } on Object catch (error, stackTrace) {
      _log.severe('Failed to run auto backup', error, stackTrace);
    }
  }
  @override
  Future<File?> findLatestBackupInICloud() async {
    try {
      final directory = Directory(await _backupDirectoryPath());
      if (!directory.existsSync()) {
        return null;
      }
      final files = directory
          .listSync(followLinks: false)
          .whereType<File>()
          .where(_isBackupFile)
          .toList(growable: false)
        ..sort((left, right) {
          return _backupTimestampFromFileName(right.path)
              .compareTo(_backupTimestampFromFileName(left.path));
        });
      if (files.isEmpty) {
        return null;
      }
      return files.first;
    } on Object catch (error, stackTrace) {
      _log.severe('Failed to scan backups', error, stackTrace);
      return null;
    }
  }
  @override
  Future<DateTime?> getLatestBackupDate() async {
    final file = await findLatestBackupInICloud();
    if (file == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(
      _backupTimestampFromFileName(file.path),
    );
  }
  @override
  Future<BackupSnapshot?> latestBackup() async {
    final file = await findLatestBackupInICloud();
    if (file == null) {
      return null;
    }
    final timestamp = _backupTimestampFromFileName(file.path);
    return BackupSnapshot(filePath: file.path, timestamp: timestamp);
  }
  @override
  Future<BackupSnapshot?> checkForNewerBackup() async {
    final latest = await latestBackup();
    if (latest == null) {
      return null;
    }
    final lastLocalChangeTimestamp = await _settingsDao.getIntValue(
      SettingsKeys.lastLocalChange,
    );
    if (lastLocalChangeTimestamp == null) {
      return null;
    }
    if (latest.timestamp > lastLocalChangeTimestamp) {
      return latest;
    }
    return null;
  }
  @override
  Future<BackupSnapshot> exportBackup() async {
    final file = await exportToJson();
    return BackupSnapshot(
      filePath: file.path,
      timestamp: _backupTimestampFromFileName(file.path),
    );
  }
  @override
  Future<BackupSnapshot> exportBackupToFile(File file) async {
    final timestamp = _now();
    final target = File(file.path);
    await target.parent.create(recursive: true);
    final payload = await _buildExportPayload(timestamp);
    await target.writeAsString(jsonEncode(payload));
    await _settingsDao.setIntValue(
      BackupSettingsKeys.lastBackupTimestamp,
      timestamp.millisecondsSinceEpoch,
      trackLocalChange: false,
    );
    return BackupSnapshot(
      filePath: target.path,
      timestamp: timestamp.millisecondsSinceEpoch,
    );
  }
  @override
  Future<String> getBackupDirectoryPath() async {
    return _backupDirectoryPath();
  }
  @override
  Future<BackupSnapshot?> ensureDailyBackup() async {
    final before = await _settingsDao.getIntValue(
      BackupSettingsKeys.lastAutoBackupTimestamp,
    );
    await autoBackup();
    final after = await _settingsDao.getIntValue(
      BackupSettingsKeys.lastAutoBackupTimestamp,
    );
    if (after == null || after == before) {
      return null;
    }
    return latestBackup();
  }
  @override
  Future<void> importBackup(File file) => importFromJson(file);
  @override
  Future<void> dispose() async {}
  Future<Map<String, Object?>> _buildExportPayload(DateTime timestamp) async {
    final metadata = <String, Object?>{
      'app_version': _appVersion,
      'export_date': timestamp.millisecondsSinceEpoch,
      'schema_version': _db.schemaVersion,
    };
    final tables = <String, Object?>{
      'tasks': (await _db.select(_db.tasks).get())
          .map((row) => row.toJson())
          .toList(growable: false),
      'task_tags': (await _db.select(_db.taskTags).get())
          .map((row) => row.toJson())
          .toList(growable: false),
      'task_reminders': (await _db.select(_db.taskReminders).get())
          .map((row) => row.toJson())
          .toList(growable: false),
      'task_checklist_items': (await _db.select(_db.taskChecklistItems).get())
          .map((row) => row.toJson())
          .toList(growable: false),
      'user_checkins': (await _db.select(_db.userCheckins).get())
          .map((row) => row.toJson())
          .toList(growable: false),
      'ai_profile': (await _db.select(_db.aiProfile).get())
          .map((row) => row.toJson())
          .toList(growable: false),
      'settings': (await _db.select(_db.settings).get())
          .map((row) => row.toJson())
          .toList(growable: false),
    };
    return <String, Object?>{
      _metadataKey: metadata,
      _tablesKey: tables,
    };
  }
  Map<String, dynamic> _extractMetadata(Map<String, dynamic> decoded) {
    final metadata = decoded[_metadataKey];
    if (metadata is Map<String, dynamic>) {
      return metadata;
    }
    return decoded;
  }
  Map<String, dynamic> _extractTables(Map<String, dynamic> decoded) {
    final tables = decoded[_tablesKey];
    if (tables is Map<String, dynamic>) {
      return tables;
    }
    return decoded;
  }
  DateTime _readImportDate(Map<String, dynamic> metadata) {
    final exportDate = metadata['export_date'];
    if (exportDate is int) {
      return DateTime.fromMillisecondsSinceEpoch(exportDate);
    }
    if (exportDate is String) {
      final parsed = int.tryParse(exportDate);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed);
      }
    }
    return _now();
  }
  int _readSchemaVersion(
    Map<String, dynamic> metadata,
    Map<String, dynamic> decoded,
  ) {
    final candidates = <dynamic>[
      metadata['schema_version'],
      decoded['version'],
      decoded['schema_version'],
    ];
    for (final candidate in candidates) {
      if (candidate is int) {
        return candidate;
      }
      if (candidate is String) {
        final parsed = int.tryParse(candidate);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return _db.schemaVersion;
  }
  Future<void> _importTables(Map<String, dynamic> tables) async {
    final importedAiProfile = _readList<app_db.AiProfileData>(
      tables['ai_profile'],
      app_db.AiProfileData.fromJson,
    );
    final importedTasks = _readList<app_db.Task>(
      tables['tasks'],
      app_db.Task.fromJson,
    );
    final importedTaskTags = _readList<app_db.TaskTag>(
      tables['task_tags'],
      app_db.TaskTag.fromJson,
    );
    final importedTaskReminders = _readList<app_db.TaskReminder>(
      tables['task_reminders'],
      app_db.TaskReminder.fromJson,
    );
    final importedChecklistItems = _readList<app_db.TaskChecklistItem>(
      tables['task_checklist_items'],
      app_db.TaskChecklistItem.fromJson,
    );
    final importedCheckins = _readList<app_db.UserCheckin>(
      tables['user_checkins'],
      app_db.UserCheckin.fromJson,
    );
    final importedSettings = _readList<app_db.Setting>(
      tables['settings'],
      app_db.Setting.fromJson,
    );
    for (final row in importedAiProfile) {
      await _db.into(_db.aiProfile).insertOnConflictUpdate(row);
    }
    for (final row in _sortTasks(importedTasks)) {
      await _db.into(_db.tasks).insert(row);
    }
    for (final row in importedTaskTags) {
      await _db.into(_db.taskTags).insert(row);
    }
    for (final row in importedTaskReminders) {
      await _db.into(_db.taskReminders).insert(row);
    }
    for (final row in importedChecklistItems) {
      await _db.into(_db.taskChecklistItems).insert(row);
    }
    for (final row in importedCheckins) {
      await _db.into(_db.userCheckins).insert(row);
    }
    for (final row in importedSettings) {
      await _db.into(_db.settings).insertOnConflictUpdate(row);
    }
  }
  Future<void> _clearDatabase() async {
    await _db.delete(_db.taskChecklistItems).go();
    await _db.delete(_db.taskReminders).go();
    await _db.delete(_db.taskTags).go();
    await _db.delete(_db.tasks).go();
    await _db.delete(_db.userCheckins).go();
    await _db.delete(_db.aiProfile).go();
    await _db.delete(_db.settings).go();
  }
  List<T> _readList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) {
      return <T>[];
    }
    final result = <T>[];
    for (final item in value) {
      if (item is! Map) {
        continue;
      }
      try {
        final safeMap = <String, dynamic>{};
        item.forEach((key, val) {
          if (key is! String) {
            return;
          }
          if (val == null) {
            switch (key) {
              case 'isAllDay':
              case 'isPinned':
              case 'isExceptionOfRule':
              case 'isDone':
                safeMap[key] = false;
                return;
              case 'hidden':
              case 'emailNotifications':
                safeMap[key] = false;
                return;
            }
          }
          safeMap[key] = val;
        });
        result.add(fromJson(safeMap));
      } on Object catch (e) {
        _log.warning('Failed to deserialize item: $e', e);
      }
    }
    return result;
  }
  List<app_db.Task> _sortTasks(List<app_db.Task> tasks) {
    final byId = <String, app_db.Task>{
      for (final task in tasks) task.id: task,
    };
    final children = <String?, List<app_db.Task>>{};
    for (final task in tasks) {
      children.putIfAbsent(task.parentTaskId, () => <app_db.Task>[]).add(task);
    }
    final result = <app_db.Task>[];
    final visited = <String>{};
    void visit(app_db.Task task) {
      if (visited.contains(task.id)) {
        return;
      }
      visited.add(task.id);
      result.add(task);
      (children[task.id] ?? const <app_db.Task>[]).forEach(visit);
    }
    (children[null] ?? const <app_db.Task>[]).forEach(visit);
    for (final task in tasks) {
      if (!visited.contains(task.id)) {
        visit(byId[task.id] ?? task);
      }
    }
    return result;
  }
  Future<String> _backupDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    if (Platform.isMacOS) {
      return directory.path;
    }
    return p.join(
      directory.path,
      'Documents',
    );
  }
  String _backupFileStamp(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year$month${day}_$hour$minute';
  }
  int _backupTimestampFromFileName(String filePath) {
    final name = p.basename(filePath);
    final timestampText =
        name.replaceFirst(_filePrefix, '').replaceFirst(_fileExtension, '');
    final parsed = _parseBackupTimestamp(timestampText);
    if (parsed != null) {
      return parsed;
    }
    return _now().millisecondsSinceEpoch;
  }
  int? _parseBackupTimestamp(String timestampText) {
    if (timestampText.contains('_') && timestampText.length == 13) {
      final year = int.tryParse(timestampText.substring(0, 4));
      final month = int.tryParse(timestampText.substring(4, 6));
      final day = int.tryParse(timestampText.substring(6, 8));
      final hour = int.tryParse(timestampText.substring(9, 11));
      final minute = int.tryParse(timestampText.substring(11, 13));
      if (year == null ||
          month == null ||
          day == null ||
          hour == null ||
          minute == null) {
        return null;
      }
      return DateTime(year, month, day, hour, minute).millisecondsSinceEpoch;
    }
    if (RegExp(r'^\d{13,}$').hasMatch(timestampText)) {
      return int.tryParse(timestampText);
    }
    return null;
  }
  bool _isBackupFile(File file) {
    final name = p.basename(file.path);
    return name.startsWith(_filePrefix) && name.endsWith(_fileExtension);
  }
  Future<void> _pruneOldBackups({File? keepCurrent}) async {
    final directory = Directory(await _backupDirectoryPath());
    if (!directory.existsSync()) {
      return;
    }
    final backups = directory
        .listSync(followLinks: false)
        .whereType<File>()
        .where(_isBackupFile)
        .toList(growable: false)
      ..sort((left, right) {
        return _backupTimestampFromFileName(right.path)
            .compareTo(_backupTimestampFromFileName(left.path));
      });
    if (backups.length <= _maxBackupsToKeep) {
      return;
    }
    for (final file in backups.skip(_maxBackupsToKeep)) {
      if (keepCurrent != null && file.path == keepCurrent.path) {
        continue;
      }
      try {
        await file.delete();
      } on Object catch (error, stackTrace) {
        _log.warning(
          'Failed to delete old backup ${file.path}',
          error,
          stackTrace,
        );
      }
    }
  }
}

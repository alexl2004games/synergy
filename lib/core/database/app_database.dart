import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables.dart';
import 'daos/tasks_dao.dart';
import 'daos/user_checkins_dao.dart';
import 'daos/task_tags_dao.dart';
import 'daos/task_reminders_dao.dart';
import 'daos/checklist_dao.dart';
import 'daos/ai_profile_dao.dart';
import 'daos/settings_dao.dart';
import '../settings/domain/settings_keys.dart';
part 'app_database.g.dart';
@DriftDatabase(
  tables: [
    Tasks,
    TaskTags,
    TaskReminders,
    TaskChecklistItems,
    UserCheckins,
    AiProfile,
    Settings,
  ],
  daos: [
    TasksDao,
    TaskTagsDao,
    TaskRemindersDao,
    ChecklistDao,
    CheckInsDao,
    AiProfileDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 4;
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX IF NOT EXISTS task_tags_task_id_idx '
            'ON task_tags (task_id);',
          );
          await _ensureLocalChangeTracking();
          await _seedIfNeeded();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(taskTags, taskTags.isPrimary);
          }
          if (from < 3) {
            await m.alterTable(TableMigration(taskTags));
            await m.alterTable(TableMigration(taskReminders));
          }
          if (from < 4) {
            await m.addColumn(userCheckins, userCheckins.energy);
          }
        },
        beforeOpen: (details) async {
          await _ensureLocalChangeTracking();
          await _seedIfNeeded();
        },
      );
  Future<void> _ensureLocalChangeTracking() async {
    const tables = <String>[
      'tasks',
      'task_tags',
      'task_reminders',
      'task_checklist_items',
      'user_checkins',
      'ai_profile',
    ];
    for (final table in tables) {
      await _createTouchTrigger(table, 'INSERT');
      await _createTouchTrigger(table, 'UPDATE');
      await _createTouchTrigger(table, 'DELETE');
    }
  }
  Future<void> _createTouchTrigger(String table, String event) async {
    await customStatement(
      '''
      CREATE TRIGGER IF NOT EXISTS ${table}_touch_last_local_change_$event
      AFTER $event ON $table
      BEGIN
        INSERT INTO settings (key, value)
        VALUES ('${SettingsKeys.lastLocalChange}',
            CAST(strftime('%s', 'now') AS INTEGER) * 1000)
        ON CONFLICT(key) DO UPDATE SET value = excluded.value;
      END;
      ''',
    );
  }
  Future<void> _seedIfNeeded() async {
    final firstRun = await (select(settings)
          ..where((row) => row.key.equals(_firstRunKey)))
        .getSingleOrNull();
    if (firstRun != null) {
      return;
    }
    final now = DateTime.now();
    final currentMillis = now.millisecondsSinceEpoch;
    await transaction(() async {
      await into(aiProfile).insertOnConflictUpdate(
        AiProfileCompanion.insert(
          id: const Value('main'),
          correctionFactor: const Value(1.0),
          avgMoodScore: const Value(0.0),
          peakHoursStart: const Value(9),
          peakHoursEnd: const Value(12),
          totalCheckins: const Value(0),
          updatedAt: currentMillis,
        ),
      );

      await into(settings).insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: _firstRunKey,
          value: 'true',
        ),
      );
    });
  }
}
const String _firstRunKey = 'first_run';
extension LegacyDaoAliases on AppDatabase {
  CheckInsDao get userCheckinsDao => checkInsDao;
}
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'smart_diary.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (database) {
        database.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}

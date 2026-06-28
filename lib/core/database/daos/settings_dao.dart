import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';
import '../../settings/domain/settings_keys.dart';
part 'settings_dao.g.dart';
@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);
  Future<void> _touchLastLocalChange() async {
    await _setValue(
      SettingsKeys.lastLocalChange,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
  Future<void> _setValue(String key, String value) {
    return into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        key: key,
        value: value,
      ),
    );
  }
  Future<String?> getValue(String key) {
    return (select(settings)..where((s) => s.key.equals(key)))
        .map((row) => row.value)
        .getSingleOrNull();
  }
  Future<int?> getIntValue(String key) async {
    final value = await getValue(key);
    if (value == null) {
      return null;
    }
    return int.tryParse(value);
  }
  Future<bool?> getBoolValue(String key) async {
    final value = await getValue(key);
    if (value == null) {
      return null;
    }
    return value == 'true';
  }
  Future<void> setValue(
    String key,
    String value, {
    bool trackLocalChange = true,
  }) async {
    await _setValue(key, value);
    if (trackLocalChange && key != SettingsKeys.lastLocalChange) {
      await _touchLastLocalChange();
    }
  }
  Future<void> setIntValue(
    String key,
    int value, {
    bool trackLocalChange = true,
  }) {
    return setValue(key, value.toString(), trackLocalChange: trackLocalChange);
  }
  Future<void> setBoolValue(
    String key, {
    required bool value,
    bool trackLocalChange = true,
  }) {
    return setValue(key, value.toString(), trackLocalChange: trackLocalChange);
  }
  Future<void> deleteKey(
    String key, {
    bool trackLocalChange = true,
  }) async {
    await (delete(settings)..where((s) => s.key.equals(key))).go();
    if (trackLocalChange && key != SettingsKeys.lastLocalChange) {
      await _touchLastLocalChange();
    }
  }
  Future<void> removeValue(String key) => deleteKey(key);
}

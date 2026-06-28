abstract class SettingsRepository {
  Future<String?> getValue(String key);
  Future<int?> getIntValue(String key);
  Future<bool?> getBoolValue(String key);
  Future<void> setValue(String key, String value);
  Future<void> setIntValue(String key, int value);
  Future<void> setBoolValue(String key, {required bool value});
  Future<void> deleteKey(String key);
}

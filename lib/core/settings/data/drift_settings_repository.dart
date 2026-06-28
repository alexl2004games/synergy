import '../../database/daos/settings_dao.dart';
import '../domain/settings_repository.dart';
class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._settingsDao);
  final SettingsDao _settingsDao;
  @override
  Future<String?> getValue(String key) => _settingsDao.getValue(key);
  @override
  Future<int?> getIntValue(String key) => _settingsDao.getIntValue(key);
  @override
  Future<bool?> getBoolValue(String key) => _settingsDao.getBoolValue(key);
  @override
  Future<void> setValue(String key, String value) =>
      _settingsDao.setValue(key, value);
  @override
  Future<void> setIntValue(String key, int value) =>
      _settingsDao.setIntValue(key, value);
  @override
  Future<void> setBoolValue(String key, {required bool value}) {
    return _settingsDao.setBoolValue(key, value: value);
  }
  @override
  Future<void> deleteKey(String key) => _settingsDao.deleteKey(key);
}

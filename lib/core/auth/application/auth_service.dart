import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import '../../database/daos/settings_dao.dart';
import '../../providers/database_provider.dart';
import '../../settings/domain/settings_keys.dart';
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(settingsDaoProvider));
});
class AuthService {
  AuthService(this._settingsDao);
  final SettingsDao _settingsDao;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _logger = Logger('AuthService');
  Future<bool> hasPin() async {
    final value = await _settingsDao.getValue(SettingsKeys.pinHash);
    return value != null && value.isNotEmpty;
  }
  Future<bool> isOnboardingCompleted() async {
    final value = await _settingsDao.getBoolValue(
      SettingsKeys.onboardingCompleted,
    );
    return value ?? false;
  }
  Future<void> completeOnboarding() async {
    await _settingsDao.setBoolValue(
      SettingsKeys.onboardingCompleted,
      value: true,
    );
  }
  Future<bool> setPin(String pin) async {
    try {
      final hash = BCrypt.hashpw(pin, BCrypt.gensalt());
      await _settingsDao.setValue(SettingsKeys.pinHash, hash);
      await _settingsDao.setBoolValue(SettingsKeys.pinEnabled, value: true);
      return true;
    } on Exception catch (e, stack) {
      _logger.severe('Ошибка установки PIN', e, stack);
      return false;
    }
  }
  Future<bool> verifyPin(String pin) async {
    try {
      final hash = await _settingsDao.getValue(SettingsKeys.pinHash);
      if (hash == null || hash.isEmpty) {
        return false;
      }
      return BCrypt.checkpw(pin, hash);
    } on Exception catch (e, stack) {
      _logger.severe('Ошибка проверки PIN', e, stack);
      return false;
    }
  }
  Future<void> clearPin() async {
    await _settingsDao.deleteKey(SettingsKeys.pinHash);
    await _settingsDao.setBoolValue(SettingsKeys.pinEnabled, value: false);
  }
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on Exception catch (e, stack) {
      _logger.warning('canCheckBiometrics failed', e, stack);
      return false;
    }
  }
  Future<void> setBiometricsEnabled({required bool enabled}) async {
    await _settingsDao.setBoolValue(
      SettingsKeys.biometryEnabled,
      value: enabled,
    );
  }
  Future<bool> isBiometricsEnabled() async {
    final value = await _settingsDao.getBoolValue(SettingsKeys.biometryEnabled);
    return value ?? false;
  }
  Future<bool> authenticateWithBiometrics([
    String localizedReason = 'Unlock',
  ]) async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isAvailable || !isDeviceSupported) return false;
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on Exception catch (e, stack) {
      _logger.severe('Ошибка биометрической авторизации', e, stack);
      return false;
    }
  }
}

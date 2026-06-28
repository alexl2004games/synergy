import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
class AuthSession {
  DateTime? lastUnlockAt;
  int failedAttempts = 0;
  DateTime? lockUntil;
}
class AuthRepository {
  AuthRepository(this._service) : _session = AuthSession();
  final AuthService _service;
  final AuthSession _session;
  Future<bool> verifyPin(String pin) async {
    final now = DateTime.now();
    if (_session.lockUntil != null && now.isBefore(_session.lockUntil!)) {
      return false;
    }
    final ok = await _service.verifyPin(pin);
    if (ok) {
      _session.failedAttempts = 0;
      _session.lockUntil = null;
      _session.lastUnlockAt = DateTime.now();
      return true;
    }
    _session.failedAttempts += 1;
    if (_session.failedAttempts >= 5) {
      _session.lockUntil = DateTime.now().add(const Duration(seconds: 30));
      _session.failedAttempts = 0;
    }
    return false;
  }
  Future<bool> authenticateWithBiometrics() async {
    final ok = await _service.authenticateWithBiometrics();
    if (ok) {
      _session.lastUnlockAt = DateTime.now();
      _session.failedAttempts = 0;
      _session.lockUntil = null;
    }
    return ok;
  }
  bool isLocked() {
    final now = DateTime.now();
    if (_session.lockUntil != null && now.isBefore(_session.lockUntil!)) {
      return true;
    }
    return false;
  }
  DateTime? get lastUnlockAt => _session.lastUnlockAt;
  Future<bool> isLockRequired() async {
    final hasPin = await _service.hasPin();
    if (!hasPin) {
      return false;
    }
    if (_session.lastUnlockAt == null) {
      return true;
    }
    return DateTime.now().difference(_session.lastUnlockAt!).inSeconds > 30;
  }
  Future<void> setPin(String pin) => _service.setPin(pin);
  Future<void> clearPin() => _service.clearPin();
  Future<void> setBiometricsEnabled({required bool enabled}) =>
      _service.setBiometricsEnabled(enabled: enabled);
  Future<bool> canCheckBiometrics() => _service.canCheckBiometrics();
  void logout() {
    _session.lastUnlockAt = null;
    _session.failedAttempts = 0;
    _session.lockUntil = null;
  }
}
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final svc = ref.read(authServiceProvider);
  return AuthRepository(svc);
});

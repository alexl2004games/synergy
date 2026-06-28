import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'auth_service.dart';
enum AuthState {
  initial,
  requiresOnboarding,
  locked,
  authenticated,
}
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(AuthState.initial) {
    unawaited(_init());
  }
  final AuthService _authService;
  Future<void> _init() async {
    if (state != AuthState.initial) {
      return;
    }
    final completed = await _authService.isOnboardingCompleted();
    if (state != AuthState.initial) {
      return;
    }
    if (!completed) {
      state = AuthState.requiresOnboarding;
      return;
    }
    final hasPin = await _authService.hasPin();
    if (state != AuthState.initial) {
      return;
    }
    if (!hasPin) {
      state = AuthState.authenticated;
      return;
    }
    state = AuthState.locked;
  }
  void unlock() {
    state = AuthState.authenticated;
  }
  void lock() {
    if (state == AuthState.authenticated) {
      state = AuthState.locked;
    }
  }
  Future<void> completeOnboarding() async {
    await _authService.completeOnboarding();
    final hasPin = await _authService.hasPin();
    state = hasPin ? AuthState.locked : AuthState.authenticated;
  }
  void logout() {
    state = AuthState.locked;
  }
}

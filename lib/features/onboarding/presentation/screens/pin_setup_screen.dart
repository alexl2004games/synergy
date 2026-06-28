import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/pin_pad.dart';
import '../../../../core/widgets/liquid_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/auth/application/auth_repository.dart';
import '../../../../core/auth/application/auth_service.dart';
import '../../../../core/localization/app_localizations.dart';
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});
  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}
class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = '';
  String? _first;
  String _message = '';
  static const int _pinLength = 4;
  Future<void> _onSubmit() async {
    final loc = AppLocalizations.of(context)!;
    if (_first == null) {
      setState(() {
        _first = _pin;
        _pin = '';
        _message = loc.auth_confirm_pin;
      });
      return;
    }
    if (_first != _pin) {
      setState(() {
        _first = null;
        _pin = '';
        _message = loc.auth_pin_mismatch;
      });
      return;
    }
    final repo = ref.read(authRepositoryProvider);
    await repo.setPin(_first!);
    final svc = ref.read(authServiceProvider);
    final canBio = await svc.canCheckBiometrics();
    if (canBio) {
      if (!mounted) {
        return;
      }
      final enable = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(loc.auth_biometrics_opt_in_title),
          content: Text(loc.auth_biometrics_opt_in_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(loc.no),
            ),
            TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(loc.yes),
            ),
          ],
        ),
      );
      if (enable ?? false) {
        await repo.setBiometricsEnabled(enabled: true);
      }
    }
    await svc.completeOnboarding();
    if (!mounted) {
      return;
    }
    context.go('/lock');
  }
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white : Colors.black87;
    final inactiveIndicatorColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.15);
    final indicatorBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.25);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: LiquidBackground()),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: contentColor),
                  title: Text(
                    loc.auth_pin_setup_title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: GlassContainer(
                        borderRadius: 24,
                        blur: 20,
                        bgOpacity: isDark ? 0.12 : 0.08,
                        borderOpacity: isDark ? 0.18 : 0.12,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              _first == null
                                  ? loc.auth_enter_pin
                                  : loc.auth_confirm_pin,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: contentColor,
                              ),
                            ),
                            if (_message.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                _message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_pinLength, (i) {
                                final filled = i < _pin.length;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: filled
                                          ? const Color(
                                              0xFF00FFA3,
                                            )
                                          : inactiveIndicatorColor,
                                      boxShadow: filled
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF00FFA3)
                                                    .withValues(alpha: 0.6),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                      border: Border.all(
                                        color: indicatorBorderColor,
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 40),
                            PinPad(
                              value: _pin,
                              maxLength: _pinLength,
                              onChanged: (v) => setState(() => _pin = v),
                              onBackspace: () => setState(() {
                                if (_pin.isNotEmpty) {
                                  _pin = _pin.substring(0, _pin.length - 1);
                                }
                              }),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: _pin.isEmpty
                                    ? null
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF00FFA3),
                                          Color(0xFF8B5CF6),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                color: _pin.isEmpty
                                    ? (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.05))
                                    : null,
                                border: _pin.isEmpty
                                    ? Border.all(
                                        color: (isDark
                                                ? Colors.white
                                                : Colors.black)
                                            .withValues(alpha: 0.12),
                                      )
                                    : null,
                                boxShadow: _pin.isEmpty
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFF00FFA3)
                                              .withValues(alpha: 0.25),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: ElevatedButton(
                                onPressed: _pin.isEmpty ? null : _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  loc.auth_done,
                                  style: TextStyle(
                                    color: _pin.isEmpty
                                        ? (isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.3)
                                            : Colors.black
                                                .withValues(alpha: 0.3))
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

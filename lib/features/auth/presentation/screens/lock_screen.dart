import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/application/auth_notifier.dart';
import '../../../../core/auth/application/auth_service.dart';
import '../../../../core/auth/application/auth_repository.dart';
import '../../../../core/widgets/liquid_background.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:smart_diary/core/localization/app_localizations.dart';
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});
  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}
class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  bool _isError = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_tryBiometrics());
    });
  }
  Future<void> _tryBiometrics() async {
    final repo = ref.read(authRepositoryProvider);
    final svc = ref.read(authServiceProvider);
    final enabled = await svc.isBiometricsEnabled();
    if (!enabled) return;
    if (!mounted) return;
    final success = await repo.authenticateWithBiometrics();
    if (success && mounted) {
      ref.read(authNotifierProvider.notifier).unlock();
    }
  }
  Future<void> _onPinEntered(String pin) async {
    final repo = ref.read(authRepositoryProvider);
    final locked = repo.isLocked();
    if (locked) {
      setState(() {
        _isError = true;
        _pin = '';
      });
      return;
    }
    final isValid = await repo.verifyPin(pin);
    if (isValid && mounted) {
      ref.read(authNotifierProvider.notifier).unlock();
    } else {
      setState(() {
        _pin = '';
        _isError = true;
      });
    }
  }
  void _onDigitPressed(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _isError = false;
        _pin += digit;
      });
      if (_pin.length == 4) {
        unawaited(_onPinEntered(_pin));
      }
    }
  }
  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white : Colors.black87;
    final inactiveIndicatorColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.15);
    final indicatorBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.25);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: LiquidBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: GlassContainer(
                  borderRadius: 24,
                  blur: 22,
                  bgOpacity: isDark ? 0.12 : 0.08,
                  borderOpacity: isDark ? 0.18 : 0.12,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      const _SynergyLogo(),
                      const SizedBox(height: 24),
                      Text(
                        l10n.lockScreenTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: contentColor,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final filled = _pin.length > index;
                          return Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
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
                                color: _isError
                                    ? theme.colorScheme.error
                                    : indicatorBorderColor,
                                width: 1.5,
                              ),
                            ),
                          );
                        }),
                      ),
                      if (_isError) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.invalidPin,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 36),
                      _buildNumpad(l10n),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNumpad(AppLocalizations l10n) {
    return Column(
      children: [
        _buildNumpadRow(['1', '2', '3']),
        _buildNumpadRow(['4', '5', '6']),
        _buildNumpadRow(['7', '8', '9']),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.fingerprint,
              onPressed: _tryBiometrics,
            ),
            _buildDigitButton('0'),
            _buildActionButton(
              icon: Icons.backspace_outlined,
              onPressed: _onDeletePressed,
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildNumpadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map(_buildDigitButton).toList(),
    );
  }
  Widget _buildDigitButton(String digit) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    final contentColor = isDark ? Colors.white : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              baseColor.withValues(alpha: isDark ? 0.07 : 0.06),
              baseColor.withValues(alpha: isDark ? 0.02 : 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: baseColor.withValues(alpha: isDark ? 0.14 : 0.1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onDigitPressed(digit),
            customBorder: const CircleBorder(),
            child: Center(
              child: Text(
                digit,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: contentColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    final contentColor = isDark ? Colors.white : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              baseColor.withValues(alpha: isDark ? 0.04 : 0.04),
              baseColor.withValues(alpha: isDark ? 0.01 : 0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: baseColor.withValues(alpha: isDark ? 0.1 : 0.08),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: contentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _SynergyLogo extends StatefulWidget {
  const _SynergyLogo();
  @override
  State<_SynergyLogo> createState() => _SynergyLogoState();
}
class _SynergyLogoState extends State<_SynergyLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 3,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'assets/images/synergy_icon.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

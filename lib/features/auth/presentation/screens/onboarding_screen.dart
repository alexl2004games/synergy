import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/auth/application/auth_service.dart';
import '../../../../core/auth/application/auth_notifier.dart';
import '../../../../core/settings/application/settings_providers.dart';
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _useBiometrics = false;
  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
  Future<void> _complete() async {
    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);
    if (_pinController.text.isNotEmpty) {
      if (_pinController.text.length < 4) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.pinMustBeFourDigits),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      await authService.setPin(_pinController.text);
      await ref
          .read(pinEnabledNotifierProvider.notifier)
          .setPinEnabled(enabled: true);
      if (_useBiometrics) {
        await authService.setBiometricsEnabled(enabled: true);
      }
    }
    await ref.read(authNotifierProvider.notifier).completeOnboarding();
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.onboardingSubtitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: l10n.setPinButton,
                  helperText: l10n.pinMustBeFourDigits,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.enableFaceId),
                value: _useBiometrics,
                onChanged: (v) => setState(() => _useBiometrics = v),
              ),
              const Spacer(),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _complete,
                  child: Text(l10n.setPinButton),
                ),
              TextButton(
                onPressed: () async {
                  _pinController.clear();
                  await _complete();
                },
                child: Text(l10n.skipButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

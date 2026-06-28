import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../auth/application/auth_notifier.dart';
import '../auth/application/auth_service.dart';
import '../backup/application/backup_providers.dart';
import '../notifications/application/notification_providers.dart';
import '../providers/database_provider.dart';
import '../settings/application/settings_providers.dart';
import '../settings/domain/settings_keys.dart';
import '../localization/app_localizations.dart';
import '../../features/scheduling/application/morning_proposal_notifier.dart';
class AppLifecycleGate extends ConsumerStatefulWidget {
  const AppLifecycleGate({required this.child, super.key});
  final Widget child;
  @override
  ConsumerState<AppLifecycleGate> createState() => _AppLifecycleGateState();
}
class _AppLifecycleGateState extends ConsumerState<AppLifecycleGate>
    with WidgetsBindingObserver {
  final Logger _logger = Logger('AppLifecycleGate');
  bool _bootstrapInitialized = false;
  Future<void>? _bootstrapTask;
  bool _backupStartupHandled = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_maybeInitializeNotifications());
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(_handleLifecycleState(state));
  }
  Future<void> _maybeInitializeNotifications() async {
    if (_bootstrapInitialized) {
      return;
    }
    final existingTask = _bootstrapTask;
    if (existingTask != null) {
      await existingTask;
      return;
    }
    _bootstrapTask = _performBootstrap();
    try {
      await _bootstrapTask;
    } finally {
      _bootstrapTask = null;
    }
  }
  Future<void> _performBootstrap() async {
    final authService = ref.read(authServiceProvider);
    if (!await authService.isOnboardingCompleted()) {
      return;
    }
    try {
      await ref.read(appBootstrapServiceProvider).initialize();
    } on Object catch (e) {
      _logger.severe('Error during app bootstrap', e);
    }
    _bootstrapInitialized = true;
    await _handleStartupBackupFlow();
  }
  Future<void> _handleStartupBackupFlow() async {
    if (_backupStartupHandled || !mounted) {
      return;
    }
    _backupStartupHandled = true;
    final candidate = await ref.read(fresherBackupProvider.future);
    if (!mounted) {
      return;
    }
    if (candidate != null) {
      final l10n = AppLocalizations.of(context)!;
      final restore = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.backupRestoreDialogTitle),
            content: Text(l10n.backupRestoreDialogBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.backupRestoreLaterButton),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.backupRestoreNowButton),
              ),
            ],
          );
        },
      );
      if ((restore ?? false) && mounted) {
        await ref.read(backupServiceProvider).importFromJson(
              File(candidate.filePath),
            );
        _invalidateSettingsAfterRestore();
      }
    }
    unawaited(ref.read(backupServiceProvider).autoBackup());
  }
  void _invalidateSettingsAfterRestore() {
    ref
      ..invalidate(themeModeProvider)
      ..invalidate(localeProvider)
      ..invalidate(workingHoursStartProvider)
      ..invalidate(workingHoursEndProvider)
      ..invalidate(notificationsEnabledProvider)
      ..invalidate(morningDigestEnabledProvider)
      ..invalidate(checkinReminderEnabledProvider)
      ..invalidate(taskReminderMinutesBeforeProvider)
      ..invalidate(checkinReminderHourProvider)
      ..invalidate(checkinReminderMinuteProvider)
      ..invalidate(biometryEnabledProvider)
      ..invalidate(backupAutoEnabledProvider)
      ..invalidate(latestBackupProvider)
      ..invalidate(fresherBackupProvider);
  }
  Future<void> _handleLifecycleState(AppLifecycleState state) async {
    final settingsDao = ref.read(settingsDaoProvider);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        final existing =
            await settingsDao.getIntValue(SettingsKeys.lastPausedAt);
        if (existing == null) {
          await settingsDao.setIntValue(
            SettingsKeys.lastPausedAt,
            DateTime.now().millisecondsSinceEpoch,
          );
        }
        return;
      case AppLifecycleState.resumed:
        await _maybeInitializeNotifications();
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final lastPausedAt = await settingsDao.getIntValue(
          SettingsKeys.lastPausedAt,
        );
        final hasPin = await ref.read(authServiceProvider).hasPin();
        if (hasPin && lastPausedAt != null) {
          final elapsed = nowMs - lastPausedAt;
          final timeoutSec = await settingsDao.getIntValue(
                SettingsKeys.autoLockTimeoutSeconds,
              ) ??
              60;
          final timeoutMs = timeoutSec * 1000;
          if (elapsed > timeoutMs) {
            ref.read(authNotifierProvider.notifier).lock();
          }
        }
        await settingsDao.setIntValue(SettingsKeys.lastPausedAt, nowMs);
        unawaited(
          ref
              .read(morningProposalProvider.notifier)
              .recalculate(DateTime.now()),
        );
        return;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        return;
    }
  }
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

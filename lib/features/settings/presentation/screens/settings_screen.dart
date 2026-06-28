import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../../../../core/auth/application/auth_notifier.dart';
import '../../../../core/auth/application/auth_repository.dart';
import '../../../../core/auth/application/auth_service.dart';
import '../../../../core/backup/backup.dart';
import '../../../../core/notifications/application/notification_providers.dart';
import '../../../../core/notifications/domain/settings_keys.dart'
    as notification_settings_keys;
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/settings/application/settings_providers.dart';
import '../../../../core/settings/domain/settings_keys.dart';
import 'package:uuid/uuid.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/data/drift_task_repository.dart';
import '../../../tasks/application/task_repository_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/pin_pad.dart';
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static final _logger = Logger('SettingsScreen');
  Future<void> _createBackup() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final service = ref.read(backupServiceProvider);
      BackupSnapshot snapshot;
      if (Platform.isAndroid || Platform.isIOS) {
        snapshot = await service.exportBackup();
        try {
          final tempFile = File(snapshot.filePath);
          final bytes = await tempFile.readAsBytes();
          final fileName = _buildBackupFileName(DateTime.now());
          final saved = await FilePicker.saveFile(
            dialogTitle: l10n.backupSaveDialogTitle,
            fileName: fileName,
            bytes: bytes,
          );
          if (saved != null && saved.isNotEmpty) {
            snapshot = await service.exportBackupToFile(File(saved));
          } else {
            _showSnack(l10n.backupExportSuccess, snapshot.filePath);
          }
        } on Object catch (e) {
          _logger.warning(
            'Failed to show save dialog, backup kept in app storage',
            e,
          );
        }
      } else {
        final initialDirectory = await service.getBackupDirectoryPath();
        final fileName = _buildBackupFileName(DateTime.now());
        final path = await FilePicker.saveFile(
          dialogTitle: l10n.backupSaveDialogTitle,
          fileName: fileName,
          initialDirectory: initialDirectory,
        );
        if (!mounted) {
          return;
        }
        if (path == null || path.isEmpty) {
          _showSnack(l10n.backupNoFileSelected);
          return;
        }
        snapshot = await service.exportBackupToFile(File(path));
      }
      if (!mounted) {
        return;
      }
      ref.invalidate(latestBackupProvider);
      _showSnack(l10n.backupExportSuccess, snapshot.filePath);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(l10n.backupError, error.toString());
    }
  }
  Future<void> _importBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(withData: Platform.isIOS);
    if (!mounted) {
      return;
    }
    if (result == null || result.files.isEmpty) {
      _showSnack(l10n.backupNoFileSelected);
      return;
    }
    final picked = result.files.single;
    var path = picked.path;
    if (path == null) {
      final bytes = picked.bytes;
      if (bytes == null) {
        _showSnack(l10n.backupNoFileSelected);
        return;
      }
      final tmp = await getTemporaryDirectory();
      final tmpFile = File(
        p.join(tmp.path, picked.name.isNotEmpty ? picked.name : 'backup.json'),
      );
      await tmpFile.writeAsBytes(bytes);
      path = tmpFile.path;
    }
    if (!path.toLowerCase().endsWith('.json')) {
      _showSnack('Недопустимый формат. Выберите JSON-файл бэкапа.');
      return;
    }
    if (!mounted) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.backupImportConfirmTitle),
          content: Text(l10n.backupImportConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.skipButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.backupImportConfirmButton),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    try {
      await ref.read(backupServiceProvider).importBackup(
            File(path),
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(latestBackupProvider);
      _showSnack(l10n.backupImportSuccess);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(l10n.backupError, error.toString());
    }
  }
  Future<void> _setBackupAutoEnabled(bool value) async {
    final settingsDao = ref.read(databaseProvider).settingsDao;
    await settingsDao.setBoolValue(
      BackupSettingsKeys.autoBackupEnabled,
      value: value,
    );
    ref.invalidate(backupAutoEnabledProvider);
  }
  String _buildBackupFileName(DateTime timestamp) {
    final date = timestamp.toLocal();
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return 'smart_diary_backup_$year$month$day$hour$minute$second.json';
  }
  Future<void> _rescheduleNotifications({
    required bool notifications,
    required bool morning,
    required bool checkin,
    required int taskLeadMinutes,
    required int checkinHour,
    required int checkinMinute,
  }) async {
    final service = ref.read(notificationServiceProvider);
    if (!notifications) {
      await service.cancelAll();
      return;
    }
    await service.cancelAll();
    if (checkin) {
      await service.scheduleCheckInReminder();
    }
    if (morning) {
      await service.scheduleWeeklyDigest();
    }
    final tasks = await ref.read(tasksDaoProvider).getAllTasks();
    final pendingTasks = tasks
        .map((task) => task.toDomain())
        .where(
          (task) =>
              task.startAt != null &&
              task.status != TaskStatus.completed &&
              task.status != TaskStatus.cancelled,
        )
        .toList(growable: false);
    for (final task in pendingTasks) {
      await service.scheduleTaskReminder(task, taskLeadMinutes);
    }
  }
  void _showSnack(String text, [String? details]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(details == null ? text : '$text $details')),
    );
  }
  Future<void> _logout() async {
    ref.read(authRepositoryProvider).logout();
    ref.read(authNotifierProvider.notifier).logout();
    if (mounted) {
      context.go('/lock');
    }
  }
  Future<void> _generateDemoTasks() async {
    final repo = ref.read(taskRepositoryProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const uuid = Uuid();
    final demoTasks = [
      Task(
        id: uuid.v4(),
        title: 'Утренняя тренировка в спортзале',
        notes: 'Разминка, кардио и силовые упражнения.',
        startAt: today.add(const Duration(hours: 8, minutes: 30)),
        endAt: today.add(const Duration(hours: 9, minutes: 30)),
        estMin: 60,
        isPinned: true,
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Рабочий созвон: Синергия релиз',
        notes:
            'Обсуждение интеграции Sherpa-ONNX и NLP движка, исправление критических багов.',
        startAt: today.add(const Duration(hours: 10)),
        endAt: today.add(const Duration(hours: 11, minutes: 30)),
        estMin: 90,
        isPinned: true,
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Обед с коллегами',
        notes: 'Обсуждение планов на неделю в кафе.',
        startAt: today.add(const Duration(hours: 13)),
        endAt: today.add(const Duration(hours: 14)),
        estMin: 60,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Ревью пул-реквестов',
        notes: 'Проверка веток адаптации и балансировщика задач.',
        startAt: today.add(const Duration(hours: 15)),
        endAt: today.add(const Duration(hours: 16, minutes: 30)),
        estMin: 90,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Купить продукты домой',
        notes: 'Молоко, сыр, овощи, хлеб.',
        startAt: today.add(const Duration(hours: 19)),
        endAt: today.add(const Duration(hours: 19, minutes: 30)),
        priority: TaskPriority.low,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Подготовка презентации по ВКР',
        notes:
            'Слайды по архитектуре локального ИИ, базе Drift ORM и аудио-тракту.',
        startAt: today.add(const Duration(days: 1, hours: 10)),
        endAt: today.add(const Duration(days: 1, hours: 12, minutes: 30)),
        estMin: 150,
        isPinned: true,
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Звонок научному руководителю',
        notes: 'Согласование финальной версии пояснительной записки и доклада.',
        startAt: today.add(const Duration(days: 1, hours: 14, minutes: 30)),
        endAt: today.add(const Duration(days: 1, hours: 15)),
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Помыть машину',
        notes: 'Полная мойка кузова и чистка салона.',
        startAt: today.add(const Duration(days: 1, hours: 16)),
        endAt: today.add(const Duration(days: 1, hours: 17)),
        estMin: 60,
        priority: TaskPriority.low,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Пробежка в парке',
        notes: 'Интервальный бег 5 км.',
        startAt: today.add(const Duration(days: 1, hours: 18, minutes: 30)),
        endAt: today.add(const Duration(days: 1, hours: 19, minutes: 15)),
        estMin: 45,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Генеральная репетиция защиты',
        notes:
            'Репетиция выступления перед зеркалом с таймером. Рассказ о Day Balancer и Effective Priority.',
        startAt: today.add(const Duration(days: 2, hours: 11)),
        endAt: today.add(const Duration(days: 2, hours: 12, minutes: 30)),
        estMin: 90,
        isPinned: true,
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Сессия ребалансировки задач',
        notes:
            'Тестирование перераспределения нагрузки и проверка свободных слотов.',
        startAt: today.add(const Duration(days: 2, hours: 14)),
        endAt: today.add(const Duration(days: 2, hours: 14, minutes: 45)),
        estMin: 45,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: uuid.v4(),
        title: 'Починить замок на рюкзаке',
        notes: 'Зайти в мастерскую ремонта металлофурнитуры.',
        startAt: today.add(const Duration(days: 2, hours: 16)),
        endAt: today.add(const Duration(days: 2, hours: 16, minutes: 30)),
        priority: TaskPriority.low,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    try {
      for (final task in demoTasks) {
        await repo.save(task);
      }
      _showSnack(
        'Демо-задачи успешно созданы на сегодня, завтра и послезавтра!',
      );
    } on Object catch (e) {
      _showSnack('Ошибка при создании демо-задач:', e.toString());
    }
  }
  Future<void> _clearAllTasks() async {
    final db = ref.read(databaseProvider);
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить все задачи?'),
          content: const Text(
            'Это действие безвозвратно удалит все задачи из базы данных.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.skipButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await db.delete(db.tasks).go();
      final service = ref.read(notificationServiceProvider);
      await service.cancelAll();
      final settingsDao = db.settingsDao;
      final checkin = await settingsDao.getBoolValue(
          notification_settings_keys.SettingsKeys.checkinReminderEnabled,) ?? true;
      if (checkin) {
        await service.scheduleCheckInReminder();
      }
      final morning = await settingsDao.getBoolValue(
          notification_settings_keys.SettingsKeys.morningDigestEnabled,) ?? true;
      if (morning) {
        await service.scheduleWeeklyDigest();
      }
      _showSnack('Все задачи и их следы полностью удалены.');
    } on Object catch (e) {
      _showSnack('Ошибка при удалении задач:', e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final latestBackupAsync = ref.watch(latestBackupProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);
    final workingHours = ref.watch(workingHoursNotifierProvider);
    final workingHoursWeekend = ref.watch(workingHoursWeekendNotifierProvider);
    final notificationsAsync = ref.watch(notificationsEnabledProvider);
    final morningDigestAsync = ref.watch(morningDigestEnabledProvider);
    final checkinReminderAsync = ref.watch(checkinReminderEnabledProvider);
    final taskReminderMinutesAsync = ref.watch(
      taskReminderMinutesBeforeProvider,
    );
    final checkinReminderHourAsync = ref.watch(checkinReminderHourProvider);
    final checkinReminderMinuteAsync = ref.watch(checkinReminderMinuteProvider);
    final biometryAsync = ref.watch(biometryEnabledProvider);
    final pinEnabled = ref.watch(pinEnabledNotifierProvider);
    final autoLockTimeout = ref.watch(autoLockTimeoutNotifierProvider);
    final backupAutoEnabledAsync = ref.watch(backupAutoEnabledProvider);
    final checkinsAsync = ref.watch(checkinsProvider);
    final experimentalEnabled = ref.watch(experimentalFeaturesNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.settingsTab),
        actions: [
          IconButton(
            tooltip: l10n.searchTitle,
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppearanceSection(context, l10n, themeMode, locale),
          const SizedBox(height: 24),
          _buildScheduleSection(
            context,
            l10n,
            workingHours.start,
            workingHours.end,
            workingHoursWeekend.start,
            workingHoursWeekend.end,
          ),
          const SizedBox(height: 24),
          _buildSecuritySection(
            context,
            l10n,
            pinEnabled,
            autoLockTimeout,
            biometryAsync.maybeWhen(
              data: (b) => b,
              orElse: () => false,
            ),
          ),
          const SizedBox(height: 24),
          notificationsAsync.when(
            data: (notif) => morningDigestAsync.when(
              data: (morning) => checkinReminderAsync.when(
                data: (checkin) => taskReminderMinutesAsync.when(
                  data: (taskLeadMinutes) => checkinReminderHourAsync.when(
                    data: (checkinHour) => checkinReminderMinuteAsync.when(
                      data: (checkinMinute) => _buildNotificationsSection(
                        context,
                        l10n,
                        notif,
                        morning,
                        checkin,
                        taskLeadMinutes,
                        checkinHour,
                        checkinMinute,
                      ),
                      loading: () => const SizedBox(
                        height: 16,
                        child: LinearProgressIndicator(),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    loading: () => const SizedBox(
                      height: 16,
                      child: LinearProgressIndicator(),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox(
                    height: 16,
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox(
                  height: 16,
                  child: LinearProgressIndicator(),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              loading: () =>
                  const SizedBox(height: 16, child: LinearProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            loading: () =>
                const SizedBox(height: 16, child: LinearProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          checkinsAsync.when(
            data: (checkins) => GlassContainer(
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Text(l10n.analyticsRecentCheckins),
                subtitle: Text(
                  checkins.isEmpty
                      ? l10n.analyticsNoData
                      : '${checkins.length} чекинов',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/analytics');
                },
              ),
            ),
            loading: () => const GlassContainer(
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Text('Чекины'),
                subtitle: Text('Загрузка...'),
              ),
            ),
            error: (_, __) => const GlassContainer(
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Text('Чекины'),
                subtitle: Text('Ошибка'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildBackupSection(
            context,
            l10n,
            latestBackupAsync,
            backupAutoEnabledAsync,
          ),
          const SizedBox(height: 24),
          _buildExperimentalSection(
            context,
            experimentalEnabled,
          ),
          const SizedBox(height: 24),
          _buildAboutSection(context, l10n),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  Widget _buildExperimentalSection(
    BuildContext context,
    bool experimentalEnabled,
  ) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Тестируемые функции',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Экспериментальные возможности, которые пока в разработке: командный центр ИИ Синергии (управление задачами голосом и текстом), диагностика NLP-разбора.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Включить тестируемые функции'),
            subtitle: const Text('Покажет кнопку командного центра ИИ'),
            value: experimentalEnabled,
            onChanged: (value) {
              unawaited(
                ref
                    .read(experimentalFeaturesNotifierProvider.notifier)
                    .setEnabled(enabled: value),
              );
              ref.invalidate(experimentalFeaturesEnabledProvider);
            },
          ),
          if (experimentalEnabled) ...[
            const Divider(height: 20),
            Text(
              'Демо-данные',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Заполнение календаря и входящих задач реалистичным расписанием для презентации возможностей приложения.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _generateDemoTasks,
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Создать демо-задачи'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearAllTasks,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Очистить всё'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Инструменты диагностики',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Запуск интерактивного разбора запросов через локальную модель Gemma 4 NLP с подробным логированием.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.push('/gemma-diagnostic'),
              icon: const Icon(Icons.psychology_outlined),
              label: const Text('Тестировать NLP'),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildAppearanceSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeMode themeMode,
    Locale locale,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appearanceSectionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.themeSectionTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(l10n.themeOptionLight),
                icon: const Icon(Icons.light_mode),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(l10n.themeOptionDark),
                icon: const Icon(Icons.dark_mode),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(l10n.themeOptionSystem),
                icon: const Icon(Icons.brightness_auto),
              ),
            ],
            selected: <ThemeMode>{themeMode},
            onSelectionChanged: (newSelection) {
              _logger.info('theme selection changed: $newSelection');
              unawaited(
                ref
                    .read(themeModeNotifierProvider.notifier)
                    .setThemeMode(newSelection.first),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.languageSectionTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (locale.languageCode == 'ru')
                FilledButton(
                  onPressed: () async {
                    _logger.info('language ru button pressed');
                    await ref
                        .read(localeNotifierProvider.notifier)
                        .setLocale(const Locale('ru'));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Язык интерфейса: Русский'),
                      ),
                    );
                  },
                  child: Text(l10n.languageOptionRu),
                )
              else
                OutlinedButton(
                  onPressed: () async {
                    _logger.info('language ru button pressed');
                    await ref
                        .read(localeNotifierProvider.notifier)
                        .setLocale(const Locale('ru'));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Язык интерфейса: Русский'),
                      ),
                    );
                  },
                  child: Text(l10n.languageOptionRu),
                ),
              const SizedBox(width: 12),
              if (locale.languageCode == 'en')
                FilledButton(
                  onPressed: () async {
                    _logger.info('language en button pressed');
                    await ref
                        .read(localeNotifierProvider.notifier)
                        .setLocale(const Locale('en'));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language: English'),
                      ),
                    );
                  },
                  child: Text(l10n.languageOptionEn),
                )
              else
                OutlinedButton(
                  onPressed: () async {
                    _logger.info('language en button pressed');
                    await ref
                        .read(localeNotifierProvider.notifier)
                        .setLocale(const Locale('en'));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language: English'),
                      ),
                    );
                  },
                  child: Text(l10n.languageOptionEn),
                ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildScheduleSection(
    BuildContext context,
    AppLocalizations l10n,
    int weekdayStart,
    int weekdayEnd,
    int weekendStart,
    int weekendEnd,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scheduleSectionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scheduleDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.workingHoursWeekdaysLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    _logger.info('weekday start time picker opened');
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: weekdayStart, minute: 0),
                    );
                    if (picked != null) {
                      await ref
                          .read(workingHoursNotifierProvider.notifier)
                          .setWorkingHours(picked.hour, weekdayEnd);
                    }
                  },
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    TimeOfDay(hour: weekdayStart, minute: 0).format(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    _logger.info('weekday end time picker opened');
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: weekdayEnd, minute: 0),
                    );
                    if (picked != null) {
                      await ref
                          .read(workingHoursNotifierProvider.notifier)
                          .setWorkingHours(weekdayStart, picked.hour);
                    }
                  },
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    TimeOfDay(hour: weekdayEnd, minute: 0).format(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.workingHoursWeekendsLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    _logger.info('weekend start time picker opened');
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: weekendStart, minute: 0),
                    );
                    if (picked != null) {
                      await ref
                          .read(
                            workingHoursWeekendNotifierProvider.notifier,
                          )
                          .setWeekendWorkingHours(picked.hour, weekendEnd);
                    }
                  },
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    TimeOfDay(hour: weekendStart, minute: 0).format(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    _logger.info('weekend end time picker opened');
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: weekendEnd, minute: 0),
                    );
                    if (picked != null) {
                      await ref
                          .read(
                            workingHoursWeekendNotifierProvider.notifier,
                          )
                          .setWeekendWorkingHours(weekendStart, picked.hour);
                    }
                  },
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    TimeOfDay(hour: weekendEnd, minute: 0).format(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<bool?>(
            future: ref
                .read(databaseProvider)
                .settingsDao
                .getBoolValue(SettingsKeys.defaultTaskPinned),
            builder: (context, snapshot) {
              final value = snapshot.data ?? false;
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: value,
                onChanged: (v) async {
                  await ref.read(databaseProvider).settingsDao.setBoolValue(
                        SettingsKeys.defaultTaskPinned,
                        value: v ?? false,
                      );
                  ref.invalidate(defaultTaskPinnedProvider);
                  setState(() {});
                },
                title: Text(l10n.taskPinnedLabel),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await ref
                  .read(workingHoursNotifierProvider.notifier)
                  .setWorkingHours(9, 18);
              await ref
                  .read(workingHoursWeekendNotifierProvider.notifier)
                  .setWeekendWorkingHours(10, 16);
            },
            icon: const Icon(Icons.restore),
            label: Text(l10n.resetToDefaultButton),
          ),
        ],
      ),
    );
  }
  Widget _buildSecuritySection(
    BuildContext context,
    AppLocalizations l10n,
    bool pinEnabled,
    int autoLockTimeout,
    bool biometry,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.securitySectionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.pinEnabledLabel),
            value: pinEnabled,
            onChanged: (value) async {
              _logger.info('pin enabled changed: $value');
              if (value == false) {
                final success = await showDialog<bool>(
                  context: context,
                  builder: (c) => const _ChangePinDialog(isDisableFlow: true),
                );
                if (success ?? false) {
                  final repo = ref.read(authRepositoryProvider);
                  await repo.clearPin();
                  await ref
                      .read(pinEnabledNotifierProvider.notifier)
                      .setPinEnabled(enabled: false);
                  _showSnack('Защита по PIN-коду отключена');
                }
              } else {
                final success = await showDialog<bool>(
                  context: context,
                  builder: (c) => const _ChangePinDialog(),
                );
                if (success ?? false) {
                  await ref
                      .read(pinEnabledNotifierProvider.notifier)
                      .setPinEnabled(enabled: true);
                  _showSnack('Защита по PIN-коду успешно включена');
                }
              }
            },
          ),
          if (pinEnabled) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final success = await showDialog<bool>(
                  context: context,
                  builder: (c) => const _ChangePinDialog(),
                );
                if (success ?? false) {
                  _showSnack('PIN-код успешно изменен');
                }
              },
              icon: const Icon(Icons.edit),
              label: Text(l10n.changePinButton),
            ),
          ],
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.biometryEnabled),
            value: biometry,
            onChanged: (value) async {
              _logger.info('biometry changed: $value');
              final repo = ref.read(authRepositoryProvider);
              final canBio = await repo.canCheckBiometrics();
              if (!canBio && (value ?? false)) {
                _showSnack(
                  'Биометрическая защита не поддерживается этим устройством',
                );
                return;
              }
              if (value ?? false) {
                final authenticated = await repo.authenticateWithBiometrics();
                if (!authenticated) {
                  _showSnack('Не удалось подтвердить личность');
                  return;
                }
              }
              final settingsDao = ref.read(databaseProvider).settingsDao;
              await settingsDao.setBoolValue(
                SettingsKeys.biometryEnabled,
                value: value ?? false,
              );
              ref.invalidate(biometryEnabledProvider);
              _showSnack(
                (value ?? false)
                    ? 'Биометрическая защита включена'
                    : 'Биометрическая защита выключена',
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            l10n.autoLockTimeoutLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [30, 60, 300].map((timeout) {
              String label;
              if (timeout == 30) {
                label = l10n.autoLockTimeout30s;
              } else if (timeout == 60) {
                label = l10n.autoLockTimeout1m;
              } else {
                label = l10n.autoLockTimeout5m;
              }
              return ChoiceChip(
                label: Text(label),
                selected: autoLockTimeout == timeout,
                onSelected: (selected) {
                  if (selected) {
                    unawaited(
                      ref
                          .read(autoLockTimeoutNotifierProvider.notifier)
                          .setAutoLockTimeout(timeout),
                    );
                  }
                },
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              _logger.info('logout pressed');
              unawaited(_logout());
            },
            icon: const Icon(Icons.logout),
            label: Text(l10n.logoutButton),
          ),
        ],
      ),
    );
  }
  Widget _buildNotificationsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool notif,
    bool morning,
    bool checkin,
    int taskLeadMinutes,
    int checkinHour,
    int checkinMinute,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationsSectionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: Text(l10n.notificationsEnabled),
            value: notif,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) async {
              _logger.info('notifications enabled changed: $value');
              if (value ?? false) {
                final service = ref.read(notificationServiceProvider);
                await service.requestPermission();
              }
              await ref
                  .read(notificationSettingsNotifierProvider.notifier)
                  .setNotificationSettings(
                    notifications: value ?? true,
                    morning: morning,
                    checkin: checkin,
                  );
              ref.invalidate(notificationsEnabledProvider);
              await _rescheduleNotifications(
                notifications: value ?? true,
                morning: morning,
                checkin: checkin,
                taskLeadMinutes: taskLeadMinutes,
                checkinHour: checkinHour,
                checkinMinute: checkinMinute,
              );
            },
          ),
          if (!notif)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notificationsDisabled,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton.icon(
                  onPressed: () async {
                    _logger.info('open system settings pressed');
                    try {
                      await openAppSettings();
                    } on MissingPluginException catch (_) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Не могу открыть системные настройки на этой платформе',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(l10n.openSettingsButton),
                ),
              ],
            ),
          if (notif) ...[
            const SizedBox(height: 8),
            CheckboxListTile(
              title: Text(l10n.taskRemindersLabel),
              value: true,
              contentPadding: EdgeInsets.zero,
              enabled: notif,
              onChanged: null,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: DropdownButton<int>(
                value: taskLeadMinutes,
                items: const [5, 10, 15, 30, 60]
                    .map(
                      (value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value ${l10n.minutesLabel}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  _logger.info('task reminder minutes changed: $value');
                  if (value == null) {
                    return;
                  }
                  final settingsDao = ref.read(databaseProvider).settingsDao;
                  unawaited(
                    settingsDao.setIntValue(
                      notification_settings_keys
                          .SettingsKeys.taskReminderMinutesBefore,
                      value,
                    ),
                  );
                  unawaited(
                    _rescheduleNotifications(
                      notifications: notif,
                      morning: morning,
                      checkin: checkin,
                      taskLeadMinutes: value,
                      checkinHour: checkinHour,
                      checkinMinute: checkinMinute,
                    ),
                  );
                  ref.invalidate(taskReminderMinutesBeforeProvider);
                },
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: Text(l10n.morningDigestEnabled),
              value: morning,
              contentPadding: EdgeInsets.zero,
              enabled: notif,
              onChanged: notif
                  ? (value) async {
                      _logger.info('morning digest changed: $value');
                      await ref
                          .read(
                            notificationSettingsNotifierProvider.notifier,
                          )
                          .setNotificationSettings(
                            notifications: notif,
                            morning: value ?? true,
                            checkin: checkin,
                          );
                      await _rescheduleNotifications(
                        notifications: notif,
                        morning: value ?? true,
                        checkin: checkin,
                        taskLeadMinutes: taskLeadMinutes,
                        checkinHour: checkinHour,
                        checkinMinute: checkinMinute,
                      );
                      ref.invalidate(morningDigestEnabledProvider);
                    }
                  : null,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: Text(l10n.checkinReminderEnabled),
              value: checkin,
              contentPadding: EdgeInsets.zero,
              enabled: notif,
              onChanged: notif
                  ? (value) async {
                      _logger.info('checkin reminder changed: $value');
                      await ref
                          .read(
                            notificationSettingsNotifierProvider.notifier,
                          )
                          .setNotificationSettings(
                            notifications: notif,
                            morning: morning,
                            checkin: value ?? true,
                          );
                      await _rescheduleNotifications(
                        notifications: notif,
                        morning: morning,
                        checkin: value ?? true,
                        taskLeadMinutes: taskLeadMinutes,
                        checkinHour: checkinHour,
                        checkinMinute: checkinMinute,
                      );
                      ref.invalidate(checkinReminderEnabledProvider);
                    }
                  : null,
            ),
            if (checkin) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: OutlinedButton.icon(
                  onPressed: notif
                      ? () async {
                          _logger.info('checkin time picker opened');
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: checkinHour,
                              minute: checkinMinute,
                            ),
                          );
                          if (picked == null) {
                            return;
                          }
                          final settingsDao =
                              ref.read(databaseProvider).settingsDao;
                          await settingsDao.setIntValue(
                            notification_settings_keys
                                .SettingsKeys.checkinReminderHour,
                            picked.hour,
                          );
                          await settingsDao.setIntValue(
                            notification_settings_keys
                                .SettingsKeys.checkinReminderMinute,
                            picked.minute,
                          );
                          await _rescheduleNotifications(
                            notifications: notif,
                            morning: morning,
                            checkin: checkin,
                            taskLeadMinutes: taskLeadMinutes,
                            checkinHour: picked.hour,
                            checkinMinute: picked.minute,
                          );
                          ref
                            ..invalidate(checkinReminderHourProvider)
                            ..invalidate(checkinReminderMinuteProvider);
                        }
                      : null,
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    TimeOfDay(hour: checkinHour, minute: checkinMinute)
                        .format(context),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
  Widget _buildBackupSection(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<BackupSnapshot?> latestBackupAsync,
    AsyncValue<bool> backupAutoEnabledAsync,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.backupSectionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(l10n.backupSectionBody),
          const SizedBox(height: 16),
          backupAutoEnabledAsync.when(
            data: (enabled) => SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.backupAutoBackupTitle),
              subtitle: Text(l10n.backupAutoBackupBody),
              value: enabled,
              onChanged: (value) {
                unawaited(_setBackupAutoEnabled(value));
              },
            ),
            loading: () => const SizedBox(
              height: 24,
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          latestBackupAsync.when(
            data: (snapshot) {
              String backupInfo;
              if (snapshot == null) {
                backupInfo = l10n.backupNoBackupYet;
              } else {
                final formattedDate =
                    MaterialLocalizations.of(context).formatMediumDate(
                  snapshot.dateTime,
                );
                final formattedTime =
                    MaterialLocalizations.of(context).formatTimeOfDay(
                  TimeOfDay.fromDateTime(snapshot.dateTime),
                );
                backupInfo =
                    '${l10n.backupLastBackupLabel}: $formattedDate $formattedTime';
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(backupInfo),
                  const SizedBox(height: 12),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 24,
              child: LinearProgressIndicator(),
            ),
            error: (error, stackTrace) => Text('$error'),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () {
                  _logger.info('create backup pressed');
                  unawaited(_createBackup());
                },
                icon: const Icon(Icons.backup),
                label: Text(l10n.backupCreateButton),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _logger.info('import backup pressed');
                  unawaited(_importBackup());
                },
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.backupImportButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aboutSectionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(l10n.appVersion('0.1b (28 июня 2026)')),
          const SizedBox(height: 4),
          Text(l10n.appDeveloper),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              showLicensePage(context: context);
            },
            icon: const Icon(Icons.description),
            label: Text(l10n.licensesButton),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.openSourceProjectsLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildProjectLink(
                context,
                'Flutter Gemma',
                'https://github.com/google-ai-edge/flutter-ai-gemma',
              ),
              _buildProjectLink(
                context,
                'Sherpa ONNX',
                'https://github.com/k2-fsa/sherpa-onnx',
              ),
              _buildProjectLink(
                context,
                'Riverpod',
                'https://github.com/rrousselGit/riverpod',
              ),
              _buildProjectLink(
                context,
                'GoRouter',
                'https://github.com/flutter/packages/tree/main/packages/go_router',
              ),
              _buildProjectLink(
                context,
                'alexl2004games / synergy',
                'https://github.com/alexl2004games/synergy',
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildProjectLink(BuildContext context, String name, String url) {
    return TextButton.icon(
      onPressed: () async {
        if (await canLaunchUrlString(url)) {
          await launchUrlString(url, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Не удалось открыть: $url')),
            );
          }
        }
      },
      icon: const Icon(Icons.open_in_new),
      label: Text(name),
    );
  }
}
class _ChangePinDialog extends ConsumerStatefulWidget {
  const _ChangePinDialog({
    this.isDisableFlow = false,
  });
  final bool isDisableFlow;
  @override
  ConsumerState<_ChangePinDialog> createState() => _ChangePinDialogState();
}
class _ChangePinDialogState extends ConsumerState<_ChangePinDialog> {
  String _pin = '';
  String? _first;
  String _message = '';
  late String _step;
  bool _hasCurrentPin = false;
  @override
  void initState() {
    super.initState();
    _step = 'enter_new';
    Future(() async {
      final hasPin = await ref.read(authServiceProvider).hasPin();
      if (hasPin) {
        setState(() {
          _hasCurrentPin = true;
          _step = 'enter_current';
        });
      }
    });
  }
  void _onPinChanged(String value) {
    if (value.length > 4) return;
    setState(() {
      _pin = value;
      _message = '';
    });
    if (value.length == 4) {
      unawaited(_handlePinSubmitted(value));
    }
  }
  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _message = '';
      });
    }
  }
  Future<void> _handlePinSubmitted(String pin) async {
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    if (_step == 'enter_current') {
      final ok = await ref.read(authRepositoryProvider).verifyPin(pin);
      if (ok) {
        if (widget.isDisableFlow) {
          if (!mounted) return;
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _step = 'enter_new';
            _pin = '';
            _message = '';
          });
        }
      } else {
        setState(() {
          _pin = '';
          _message = 'Неверный текущий PIN-код';
        });
      }
    } else if (_step == 'enter_new') {
      setState(() {
        _first = pin;
        _pin = '';
        _step = 'confirm_new';
        _message = '';
      });
    } else if (_step == 'confirm_new') {
      if (_first == pin) {
        await ref.read(authRepositoryProvider).setPin(pin);
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _first = null;
          _pin = '';
          _step = 'enter_new';
          _message = loc.auth_pin_mismatch;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    String instruction;
    if (_step == 'enter_current') {
      instruction = 'Введите текущий PIN-код';
    } else if (_step == 'enter_new') {
      instruction =
          _hasCurrentPin ? 'Введите новый PIN-код' : loc.auth_pin_setup_title;
    } else {
      instruction = loc.auth_confirm_pin;
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassContainer(
        borderRadius: 24,
        blur: 24,
        bgOpacity: isDark ? 0.25 : 0.15,
        borderOpacity: isDark ? 0.15 : 0.25,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isDisableFlow
                      ? 'Отключение защиты'
                      : 'Настройка PIN-кода',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              instruction,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: filled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            PinPad(
              value: _pin,
              maxLength: 4,
              onChanged: _onPinChanged,
              onBackspace: _onBackspace,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../database/daos/settings_dao.dart';
import '../../providers/database_provider.dart';
import '../domain/settings_keys.dart';
import '../../notifications/domain/settings_keys.dart'
    as notification_settings_keys;
final themeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final db = ref.watch(databaseProvider);
  final settingsDao = db.settingsDao;
  final value = await settingsDao.getValue(SettingsKeys.themeMode);
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});
final themeModeNotifierProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) {
    final db = ref.watch(databaseProvider);
    return ThemeModeNotifier(db.settingsDao);
  },
);
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._settingsDao) : super(ThemeMode.system) {
    _init();
  }
  Future<void> _init() async {
    final value = await _settingsDao.getValue(SettingsKeys.themeMode);
    if (value == 'light') {
      state = ThemeMode.light;
    } else if (value == 'dark') {
      state = ThemeMode.dark;
    }
  }
  final SettingsDao _settingsDao;
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _settingsDao.setValue(SettingsKeys.themeMode, value);
  }
}
final localeProvider = FutureProvider<Locale>((ref) async {
  final db = ref.watch(databaseProvider);
  final settingsDao = db.settingsDao;
  final value = await settingsDao.getValue(SettingsKeys.locale);
  if (value == 'ru') {
    return const Locale('ru');
  }
  return const Locale('ru');
});
final localeNotifierProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) {
    final db = ref.watch(databaseProvider);
    return LocaleNotifier(db.settingsDao);
  },
);
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._settingsDao) : super(const Locale('ru')) {
    _init();
  }
  Future<void> _init() async {
    final value = await _settingsDao.getValue(SettingsKeys.locale);
    if (value == 'en') state = const Locale('en');
  }
  final SettingsDao _settingsDao;
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final value = locale.languageCode == 'ru' ? 'ru' : 'en';
    await _settingsDao.setValue(SettingsKeys.locale, value);
  }
}
final workingHoursStartProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final value =
      await db.settingsDao.getIntValue(SettingsKeys.workingHoursStart);
  return value ?? 9;
});
final workingHoursEndProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getIntValue(SettingsKeys.workingHoursEnd);
  return value ?? 18;
});
final workingHoursWeekendStartProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final value =
      await db.settingsDao.getIntValue(SettingsKeys.workingHoursWeekendStart);
  return value ?? 10;
});
final workingHoursWeekendEndProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final value =
      await db.settingsDao.getIntValue(SettingsKeys.workingHoursWeekendEnd);
  return value ?? 16;
});
final workingHoursNotifierProvider =
    StateNotifierProvider<WorkingHoursNotifier, ({int start, int end})>((ref) {
  final db = ref.watch(databaseProvider);
  return WorkingHoursNotifier(db.settingsDao);
});
class WorkingHoursNotifier extends StateNotifier<({int start, int end})> {
  WorkingHoursNotifier(this._settingsDao) : super((start: 9, end: 18)) {
    _init();
  }
  Future<void> _init() async {
    final start = await _settingsDao.getIntValue(SettingsKeys.workingHoursStart) ?? 9;
    final end = await _settingsDao.getIntValue(SettingsKeys.workingHoursEnd) ?? 18;
    state = (start: start, end: end);
  }
  final SettingsDao _settingsDao;
  Future<void> setWorkingHours(int start, int end) async {
    state = (start: start, end: end);
    await _settingsDao.setIntValue(SettingsKeys.workingHoursStart, start);
    await _settingsDao.setIntValue(SettingsKeys.workingHoursEnd, end);
  }
}
final workingHoursWeekendNotifierProvider =
    StateNotifierProvider<WorkingHoursWeekendNotifier, ({int start, int end})>(
        (ref) {
  final db = ref.watch(databaseProvider);
  return WorkingHoursWeekendNotifier(db.settingsDao);
});
class WorkingHoursWeekendNotifier
    extends StateNotifier<({int start, int end})> {
  WorkingHoursWeekendNotifier(this._settingsDao) : super((start: 10, end: 16)) {
    _init();
  }
  Future<void> _init() async {
    final start = await _settingsDao.getIntValue(SettingsKeys.workingHoursWeekendStart) ?? 10;
    final end = await _settingsDao.getIntValue(SettingsKeys.workingHoursWeekendEnd) ?? 16;
    state = (start: start, end: end);
  }
  final SettingsDao _settingsDao;
  Future<void> setWeekendWorkingHours(int start, int end) async {
    state = (start: start, end: end);
    await _settingsDao.setIntValue(
      SettingsKeys.workingHoursWeekendStart,
      start,
    );
    await _settingsDao.setIntValue(
      SettingsKeys.workingHoursWeekendEnd,
      end,
    );
  }
}
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getBoolValue(
    notification_settings_keys.SettingsKeys.notificationsEnabled,
  );
  return value ?? true;
});
final morningDigestEnabledProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getBoolValue(
    notification_settings_keys.SettingsKeys.morningDigestEnabled,
  );
  return value ?? true;
});
final checkinReminderEnabledProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getBoolValue(
    notification_settings_keys.SettingsKeys.checkinReminderEnabled,
  );
  return value ?? true;
});
final taskReminderMinutesBeforeProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getIntValue(
    notification_settings_keys.SettingsKeys.taskReminderMinutesBefore,
  );
  return value ?? 15;
});
final checkinReminderHourProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getIntValue(
    notification_settings_keys.SettingsKeys.checkinReminderHour,
  );
  return value ?? 21;
});
final checkinReminderMinuteProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getIntValue(
    notification_settings_keys.SettingsKeys.checkinReminderMinute,
  );
  return value ?? 0;
});
final defaultTaskPinnedProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value =
      await db.settingsDao.getBoolValue(SettingsKeys.defaultTaskPinned);
  return value ?? false;
});
final notificationSettingsNotifierProvider = StateNotifierProvider<
    NotificationSettingsNotifier,
    ({bool notifications, bool morning, bool checkin})>((ref) {
  final db = ref.watch(databaseProvider);
  return NotificationSettingsNotifier(db.settingsDao);
});
class NotificationSettingsNotifier
    extends StateNotifier<({bool notifications, bool morning, bool checkin})> {
  NotificationSettingsNotifier(this._settingsDao)
      : super((notifications: true, morning: true, checkin: true)) {
    _init();
  }
  Future<void> _init() async {
    final notifications = await _settingsDao.getBoolValue(notification_settings_keys.SettingsKeys.notificationsEnabled) ?? true;
    final morning = await _settingsDao.getBoolValue(notification_settings_keys.SettingsKeys.morningDigestEnabled) ?? true;
    final checkin = await _settingsDao.getBoolValue(notification_settings_keys.SettingsKeys.checkinReminderEnabled) ?? true;
    state = (notifications: notifications, morning: morning, checkin: checkin);
  }
  final SettingsDao _settingsDao;
  Future<void> setNotificationSettings({
    required bool notifications,
    required bool morning,
    required bool checkin,
  }) async {
    state = (notifications: notifications, morning: morning, checkin: checkin);
    await _settingsDao.setBoolValue(
      notification_settings_keys.SettingsKeys.notificationsEnabled,
      value: notifications,
    );
    await _settingsDao.setBoolValue(
      notification_settings_keys.SettingsKeys.morningDigestEnabled,
      value: morning,
    );
    await _settingsDao.setBoolValue(
      notification_settings_keys.SettingsKeys.checkinReminderEnabled,
      value: checkin,
    );
  }
}
final biometryEnabledProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getBoolValue(SettingsKeys.biometryEnabled);
  return value ?? false;
});
final pinEnabledProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getBoolValue(SettingsKeys.pinEnabled);
  return value ?? false;
});
final pinEnabledNotifierProvider =
    StateNotifierProvider<PinEnabledNotifier, bool>((ref) {
  final db = ref.watch(databaseProvider);
  return PinEnabledNotifier(db.settingsDao);
});
class PinEnabledNotifier extends StateNotifier<bool> {
  PinEnabledNotifier(this._settingsDao) : super(false) {
    _init();
  }
  Future<void> _init() async {
    final value = await _settingsDao.getBoolValue(SettingsKeys.pinEnabled) ?? false;
    state = value;
  }
  final SettingsDao _settingsDao;
  Future<void> setPinEnabled({required bool enabled}) async {
    state = enabled;
    await _settingsDao.setBoolValue(
      SettingsKeys.pinEnabled,
      value: enabled,
    );
  }
}
final autoLockTimeoutProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final value =
      await db.settingsDao.getIntValue(SettingsKeys.autoLockTimeoutSeconds);
  return value ?? 60;
});
final autoLockTimeoutNotifierProvider =
    StateNotifierProvider<AutoLockTimeoutNotifier, int>((ref) {
  final db = ref.watch(databaseProvider);
  return AutoLockTimeoutNotifier(db.settingsDao);
});
class AutoLockTimeoutNotifier extends StateNotifier<int> {
  AutoLockTimeoutNotifier(this._settingsDao) : super(60) {
    _init();
  }
  Future<void> _init() async {
    final value = await _settingsDao.getIntValue(SettingsKeys.autoLockTimeoutSeconds) ?? 60;
    state = value;
  }
  final SettingsDao _settingsDao;
  Future<void> setAutoLockTimeout(int seconds) async {
    state = seconds;
    await _settingsDao.setIntValue(
      SettingsKeys.autoLockTimeoutSeconds,
      seconds,
    );
  }
}
final experimentalFeaturesEnabledProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getBoolValue(
    SettingsKeys.experimentalFeaturesEnabled,
  );
  return value ?? false;
});
final experimentalFeaturesNotifierProvider =
    StateNotifierProvider<ExperimentalFeaturesNotifier, bool>((ref) {
  final db = ref.watch(databaseProvider);
  return ExperimentalFeaturesNotifier(db.settingsDao);
});
class ExperimentalFeaturesNotifier extends StateNotifier<bool> {
  ExperimentalFeaturesNotifier(this._settingsDao) : super(false) {
    _init();
  }
  Future<void> _init() async {
    final value = await _settingsDao.getBoolValue(SettingsKeys.experimentalFeaturesEnabled) ?? false;
    state = value;
  }
  final SettingsDao _settingsDao;
  Future<void> setEnabled({required bool enabled}) async {
    state = enabled;
    await _settingsDao.setBoolValue(
      SettingsKeys.experimentalFeaturesEnabled,
      value: enabled,
    );
  }
}

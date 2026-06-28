import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../features/tasks/domain/task.dart' as task_domain;
import '../../database/app_database.dart' as app_db;
import '../../database/daos/tasks_dao.dart';
import '../../database/daos/settings_dao.dart';
import '../application/notification_service.dart';
import '../application/notification_texts.dart';
import '../domain/notification_ids.dart';
import '../domain/notification_preferences.dart';
import '../domain/settings_keys.dart';
class FlutterLocalNotificationsService implements NotificationService {
  FlutterLocalNotificationsService({
    required TasksDao tasksDao,
    required SettingsDao settingsDao,
    FlutterLocalNotificationsPlugin? plugin,
    Future<void> Function(NotificationResponse response)? onTap,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _tasksDao = tasksDao,
        _settingsDao = settingsDao,
        _onTap = onTap;
  final FlutterLocalNotificationsPlugin _plugin;
  final TasksDao _tasksDao;
  final SettingsDao _settingsDao;
  final Future<void> Function(NotificationResponse response)? _onTap;
  bool _isInitialized = false;
  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
    } on Object {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        unawaited(_onTap?.call(response));
      },
    );
    _isInitialized = true;
  }
  @override
  Future<void> init() => initialize();
  @override
  Future<void> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final mac = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
    await mac?.requestPermissions(alert: true, badge: true, sound: true);
  }
  @override
  Future<void> requestPermissions() => requestPermission();
  @override
  Future<void> scheduleTaskReminder(
    task_domain.Task task,
    int minutesBefore,
  ) async {
    await _ensureInitialized();
    final startAt = task.startAt;
    if (startAt == null) {
      return;
    }
    final scheduledDate = startAt.subtract(Duration(minutes: minutesBefore));
    final notificationDate = scheduledDate.isBefore(DateTime.now())
        ? DateTime.now().add(const Duration(seconds: 1))
        : scheduledDate;
    await _plugin.zonedSchedule(
      id: NotificationIds.stableIntId(NotificationIds.taskReminder(task.id)),
      title: NotificationTexts.current().taskReminderTitle,
      body: task.title,
      scheduledDate: tz.TZDateTime.from(notificationDate, tz.local),
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(<String, String>{
        'type': 'task_reminder',
        'taskId': task.id,
      }),
    );
  }
  @override
  Future<void> cancelTaskReminder(String taskId) async {
    await _ensureInitialized();
    await _plugin.cancel(
      id: NotificationIds.stableIntId(NotificationIds.taskReminder(taskId)),
    );
  }
  @override
  Future<void> scheduleCheckInReminder() async {
    await _ensureInitialized();
    final hour =
        await _settingsDao.getIntValue(SettingsKeys.checkinReminderHour) ?? 21;
    final minute =
        await _settingsDao.getIntValue(SettingsKeys.checkinReminderMinute) ?? 0;
    final scheduled = _nextInstanceOf(hour, minute);
    await _plugin.zonedSchedule(
      id: NotificationIds.stableIntId(NotificationIds.checkinReminder),
      title: NotificationTexts.current().checkinReminderTitle,
      body: NotificationTexts.current().checkinReminderBody,
      scheduledDate: scheduled,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'checkin',
    );
  }
  @override
  Future<void> scheduleWeeklyDigest() async {
    await _ensureInitialized();
    final weekday =
        await _settingsDao.getIntValue(SettingsKeys.morningDigestWeekday) ??
            DateTime.monday;
    final hour =
        await _settingsDao.getIntValue(SettingsKeys.morningDigestHour) ?? 8;
    final minute =
        await _settingsDao.getIntValue(SettingsKeys.morningDigestMinute) ?? 0;
    final scheduled = _nextWeekdayInstanceOf(weekday, hour, minute);
    final counts = await _weeklyDigestCounts();
    final texts = NotificationTexts.current();
    await _plugin.zonedSchedule(
      id: NotificationIds.stableIntId(NotificationIds.weeklyDigest),
      title: texts.morningDigestTitle,
      body: texts.weeklyDigestBody(
        counts.deadlineCount,
        counts.tasksCount,
      ),
      scheduledDate: scheduled,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_digest',
    );
  }
  @override
  Future<void> syncRecurringNotifications(
    NotificationPreferences preferences,
  ) async {
    await _ensureInitialized();
    if (!preferences.notificationsEnabled) {
      await cancelAll();
      return;
    }
    await scheduleCheckInReminder();
    await scheduleWeeklyDigest();
  }
  @override
  Future<void> syncTaskReminders(List<app_db.TaskReminder> reminders) async {
    await _ensureInitialized();
    if (reminders.isEmpty) {
      return;
    }
    for (final reminder in reminders) {
      await _scheduleTaskReminderRow(reminder);
    }
  }
  @override
  Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
  }
  @override
  Future<void> dispose() async {
    await cancelAll();
  }
  Future<void> _scheduleTaskReminderRow(app_db.TaskReminder reminder) async {
    final scheduledDate =
        DateTime.fromMillisecondsSinceEpoch(reminder.remindAt);
    final notificationDate = scheduledDate.isBefore(DateTime.now())
        ? DateTime.now().add(const Duration(seconds: 1))
        : scheduledDate;
    await _plugin.zonedSchedule(
      id: NotificationIds.stableIntId(reminder.id),
      title: NotificationTexts.current().taskReminderTitle,
      body: NotificationTexts.current().taskReminderBody,
      scheduledDate: tz.TZDateTime.from(notificationDate, tz.local),
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(<String, String>{
        'type': 'task_reminder',
        'taskId': reminder.taskId,
        'reminderId': reminder.id,
      }),
    );
  }
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = DateTime.now();
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
  tz.TZDateTime _nextWeekdayInstanceOf(int weekday, int hour, int minute) {
    final now = DateTime.now();
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday ||
        scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
  Future<({int tasksCount, int deadlineCount})> _weeklyDigestCounts() async {
    final tasks = await _tasksDao.getAllTasks();
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    final tasksCount = tasks.where((task) {
      final startAt = task.startAt;
      if (startAt == null) {
        return false;
      }
      final date = DateTime.fromMillisecondsSinceEpoch(startAt);
      return !date.isBefore(now) && !date.isAfter(weekEnd);
    }).length;
    final deadlineCount = tasks.where((task) {
      final deadlineAt = task.deadlineAt;
      if (deadlineAt == null) {
        return false;
      }
      final date = DateTime.fromMillisecondsSinceEpoch(deadlineAt);
      return !date.isBefore(now) && !date.isAfter(weekEnd);
    }).length;
    return (tasksCount: tasksCount, deadlineCount: deadlineCount);
  }
  NotificationDetails _details() {
    const details = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'synergy_notifications',
        'Synergy Notifications',
        channelDescription: 'Task reminders, check-ins, and weekly digest.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: details,
      macOS: details,
    );
  }
  Future<void> _ensureInitialized() async {
    if (_isInitialized) {
      return;
    }
    await initialize();
  }
}

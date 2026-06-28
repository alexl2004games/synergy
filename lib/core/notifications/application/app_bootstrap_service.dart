import 'package:logging/logging.dart';
import '../../database/app_database.dart';
import '../../database/daos/ai_profile_dao.dart';
import '../../database/daos/settings_dao.dart';
import '../../database/daos/tasks_dao.dart';
import '../../database/tables.dart';
import '../../llm/domain/ai_profile.dart';
import '../../../features/tasks/data/drift_task_repository.dart';
import '../../../features/scheduling/application/day_balancer.dart';
import '../../../features/scheduling/application/overdue_rescheduler.dart';
import '../../../features/scheduling/domain/work_window.dart';
import '../../../features/scheduling/domain/time_slot.dart';
import 'package:drift/drift.dart' as drift;
import '../../../features/recurrence/recurrence.dart';
import '../domain/morning_recalculation_report.dart';
import '../domain/notification_preferences.dart';
import '../domain/settings_keys.dart';
import 'notification_service.dart';
class AppBootstrapService {
  AppBootstrapService({
    required NotificationService notificationService,
    required TasksDao tasksDao,
    required SettingsDao settingsDao,
    required AiProfileDao aiProfileDao,
    DateTime Function()? now,
  })  : _notificationService = notificationService,
        _tasksDao = tasksDao,
        _settingsDao = settingsDao,
        _aiProfileDao = aiProfileDao,
        _now = now ?? DateTime.now,
        _recurrenceEngine = RecurrenceEngine(tasksDao: tasksDao);
  final NotificationService _notificationService;
  final TasksDao _tasksDao;
  final SettingsDao _settingsDao;
  final AiProfileDao _aiProfileDao;
  final DateTime Function() _now;
  final RecurrenceEngine _recurrenceEngine;
  final Logger _log = Logger('AppBootstrapService');
  bool _isInitialized = false;
  Future<MorningRecalculationReport?> initialize() async {
    if (_isInitialized) {
      return null;
    }
    try {
      await _notificationService.init();
      await _notificationService.requestPermissions();
      final preferences = await _loadNotificationPreferences();
      await _notificationService.syncRecurringNotifications(preferences);
      await _refreshTaskReminders(preferences);
      final report = await ensureMorningRecalculation();
      await _refreshTaskReminderNotifications(preferences);
      _isInitialized = true;
      return report;
    } on Object catch (e) {
      _log.severe('Error during app bootstrap', e);
      _isInitialized = true;
      return null;
    }
  }
  Future<MorningRecalculationReport?> ensureMorningRecalculation() async {
    final now = _now();
    final todayKey = _dateKey(now);
    final lastRunKey = await _settingsDao
        .getIntValue(SettingsKeys.lastMorningRecalculationDate);
    if (lastRunKey == todayKey) {
      return null;
    }
    final tasks = await _tasksDao.getAllTasks();
    final profile = await _loadAiProfile();
    final workWindowMinutes =
        await _settingsDao.getIntValue(SettingsKeys.workWindowMinutes) ?? 480;
    final workWindow = WorkWindow.fromMinutes(
      weekdayStart:
          await _settingsDao.getIntValue(SettingsKeys.wwWeekdayStart) ?? 9 * 60,
      weekdayEnd:
          await _settingsDao.getIntValue(SettingsKeys.wwWeekdayEnd) ?? 18 * 60,
      weekendStart:
          await _settingsDao.getIntValue(SettingsKeys.wwWeekendStart) ??
              10 * 60,
      weekendEnd:
          await _settingsDao.getIntValue(SettingsKeys.wwWeekendEnd) ?? 16 * 60,
    );
    final today = DateTime(now.year, now.month, now.day);
    final templates = await _tasksDao.getRecurrenceTemplates();
    for (final template in templates) {
      final lastInstance = tasks
          .where((t) => t.parentTaskId == template.id)
          .fold<DateTime?>(null, (prev, t) {
        if (t.startAt == null) return prev;
        final taskDate = DateTime.fromMillisecondsSinceEpoch(t.startAt!);
        return prev == null || taskDate.isAfter(prev) ? taskDate : prev;
      });
      final materializeFrom = lastInstance ?? today;
      await _recurrenceEngine.materialize(
        templateTask: template,
        startDate: materializeFrom.add(const Duration(days: 1)),
        days: 30,
      );
    }
    final allTasks = await _tasksDao.getAllTasks();
    final overdueTasks =
        allTasks.where((task) => _isOverdue(task, now)).toList(growable: false);
    final rescheduler = OverdueRescheduler(
      profile: profile,
      now: _now,
    );
    final overdueProposals = await rescheduler.proposeReschedule(
      overdueTasks: overdueTasks,
      startFromDay: today.add(const Duration(days: 1)),
      maxDaysAhead: 14,
      getTasksForDay: (day) async => allTasks
          .where((task) => _isOnDay(task, day))
          .where(
            (task) =>
                task.status == TaskStatus.pending ||
                task.status == TaskStatus.inProgress,
          )
          .toList(growable: false),
      workWindow: workWindow,
      profile: profile,
    );
    final rescheduledTasks = overdueProposals
        .where((proposal) => proposal.proposedSlot != null)
        .map((proposal) => _shiftTask(proposal.task, proposal.proposedSlot!))
        .toList(growable: false);
    for (final task in rescheduledTasks) {
      await _tasksDao.updateTask(task);
    }
    final dayTasks = allTasks
        .where((task) => _isOnDay(task, today))
        .where(
          (task) =>
              task.status == TaskStatus.pending ||
              task.status == TaskStatus.inProgress,
        )
        .toList(growable: false);
    final dayBalancer = DayBalancer(
      profile: profile,
      now: _now,
    );
    final proposal = await dayBalancer.balance(
      day: today,
      tasksOfDay: dayTasks,
      workWindow: workWindow,
      profile: profile,
      getTasksForDay: (day) async => allTasks
          .where((task) => _isOnDay(task, day))
          .where(
            (task) =>
                task.status == TaskStatus.pending ||
                task.status == TaskStatus.inProgress,
          )
          .toList(growable: false),
    );
    final dayOverflowTasks = proposal?.overflowTasks ?? const <Task>[];
    final dayKeptTasks = proposal?.keptTasks ?? dayTasks;
    await _settingsDao.setIntValue(
      SettingsKeys.lastMorningRecalculationDate,
      todayKey,
    );
    _log.info(
      'Morning recalculation completed: '
      'rescheduled=${rescheduledTasks.length}, '
      'kept=${dayKeptTasks.length}, '
      'overflow=${dayOverflowTasks.length}',
    );
    return MorningRecalculationReport(
      day: today,
      rescheduledTasks: rescheduledTasks,
      dayKeptTasks: dayKeptTasks,
      dayOverflowTasks: dayOverflowTasks,
      workWindowMinutes: workWindowMinutes,
    );
  }
  Future<void> _refreshTaskReminders(
    NotificationPreferences preferences,
  ) async {
    if (!preferences.notificationsEnabled) {
      return;
    }
    final reminders = await _tasksDao.getPendingReminders();
    await _notificationService.syncTaskReminders(reminders);
  }
  Future<void> _refreshTaskReminderNotifications(
    NotificationPreferences preferences,
  ) async {
    if (!preferences.notificationsEnabled) {
      return;
    }
    final tasks = await _tasksDao.getAllTasks();
    for (final task in tasks) {
      if (task.startAt == null ||
          task.status == TaskStatus.completed ||
          task.status == TaskStatus.cancelled) {
        continue;
      }
      await _notificationService.scheduleTaskReminder(
        task.toDomain(),
        preferences.taskReminderMinutesBefore,
      );
    }
  }
  Future<NotificationPreferences> _loadNotificationPreferences() async {
    final notificationsEnabled =
        await _settingsDao.getBoolValue(SettingsKeys.notificationsEnabled) ??
            true;
    final taskReminderMinutesBefore = await _settingsDao
            .getIntValue(SettingsKeys.taskReminderMinutesBefore) ??
        15;
    final checkinReminderHour =
        await _settingsDao.getIntValue(SettingsKeys.checkinReminderHour) ?? 21;
    final checkinReminderMinute =
        await _settingsDao.getIntValue(SettingsKeys.checkinReminderMinute) ?? 0;
    final morningDigestWeekday =
        await _settingsDao.getIntValue(SettingsKeys.morningDigestWeekday) ??
            DateTime.monday;
    final morningDigestHour =
        await _settingsDao.getIntValue(SettingsKeys.morningDigestHour) ?? 8;
    final morningDigestMinute =
        await _settingsDao.getIntValue(SettingsKeys.morningDigestMinute) ?? 0;
    return NotificationPreferences(
      notificationsEnabled: notificationsEnabled,
      taskReminderMinutesBefore: taskReminderMinutesBefore,
      checkinReminderHour: checkinReminderHour,
      checkinReminderMinute: checkinReminderMinute,
      morningDigestWeekday: morningDigestWeekday,
      morningDigestHour: morningDigestHour,
      morningDigestMinute: morningDigestMinute,
    );
  }
  Future<AIProfile> _loadAiProfile() async {
    final profile = await _aiProfileDao.getProfile();
    if (profile == null) {
      return const AIProfile();
    }
    return AIProfile(
      correctionFactor: profile.correctionFactor,
      peakHoursStart: profile.peakHoursStart,
      peakHoursEnd: profile.peakHoursEnd,
    );
  }
  bool _isOverdue(Task task, DateTime now) {
    if (task.status == TaskStatus.completed ||
        task.status == TaskStatus.cancelled) {
      return false;
    }
    final referenceMillis = task.deadlineAt ?? task.startAt;
    if (referenceMillis == null) {
      return false;
    }
    return DateTime.fromMillisecondsSinceEpoch(referenceMillis).isBefore(now);
  }
  bool _isOnDay(Task task, DateTime day) {
    final startAt = task.startAt;
    if (startAt == null) {
      return false;
    }
    final taskDay = DateTime.fromMillisecondsSinceEpoch(startAt);
    return taskDay.year == day.year &&
        taskDay.month == day.month &&
        taskDay.day == day.day;
  }
  int _dateKey(DateTime value) {
    return value.year * 10000 + value.month * 100 + value.day;
  }
  Task _shiftTask(Task task, TimeSlot slot) {
    final startAt = slot.startAt;
    final duration = task.endAt != null && task.startAt != null
        ? task.endAt! - task.startAt!
        : Duration(minutes: task.estMin).inMilliseconds;
    final endAt = startAt.millisecondsSinceEpoch + duration;
    return task.copyWith(
      startAt: drift.Value<int?>(startAt.millisecondsSinceEpoch),
      endAt: drift.Value<int?>(endAt),
      deadlineAt: task.deadlineAt == null
          ? const drift.Value<int?>(null)
          : drift.Value<int?>(
              task.deadlineAt! +
                  (startAt.millisecondsSinceEpoch -
                      (task.startAt ?? task.deadlineAt ?? task.createdAt)),
            ),
      updatedAt: _now().millisecondsSinceEpoch,
      status: TaskStatus.pending,
    );
  }
}

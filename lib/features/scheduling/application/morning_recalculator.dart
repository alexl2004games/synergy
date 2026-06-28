import '../../../core/database/app_database.dart';
import '../../../core/database/daos/ai_profile_dao.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/database/daos/tasks_dao.dart';
import '../../../core/database/tables.dart';
import '../../../core/llm/domain/ai_profile.dart';
import '../../../core/notifications/domain/settings_keys.dart';
import '../../../core/adaptation/data/drift_adaptation_repository.dart';
import 'package:drift/drift.dart' as drift;
import '../../recurrence/recurrence.dart';
import '../domain/morning_proposal.dart';
import '../domain/time_slot.dart';
import '../domain/work_window.dart';
import 'day_balancer.dart';
import 'overdue_rescheduler.dart';
class MorningRecalculator {
  MorningRecalculator({
    required TasksDao tasksDao,
    required SettingsDao settingsDao,
    required AiProfileDao aiProfileDao,
    DateTime Function()? now,
  })  : _tasksDao = tasksDao,
        _settingsDao = settingsDao,
        _aiProfileDao = aiProfileDao,
        _now = now ?? DateTime.now,
        _recurrenceEngine = RecurrenceEngine(tasksDao: tasksDao);
  final TasksDao _tasksDao;
  final SettingsDao _settingsDao;
  final AiProfileDao _aiProfileDao;
  final DateTime Function() _now;
  final RecurrenceEngine _recurrenceEngine;
  Future<MorningProposal?> recalculate(DateTime today) async {
    final now = _now();
    final todayKey = _dateKey(today);
    final lastRunKey = await _settingsDao
        .getIntValue(SettingsKeys.lastMorningRecalculationDate);
    if (lastRunKey == todayKey) {
      return null;
    }
    final tasks = await _tasksDao.getAllTasks();
    final profile = await _loadAiProfile();
    final workWindow = await _loadWorkWindow();
    await _materializeRecurrenceTasks(tasks, today);
    final allTasks = await _tasksDao.getAllTasks();
    final overdueTasks = allTasks
        .where((task) => _isOverdue(task, now))
        .where((task) => !task.isPinned)
        .toList(growable: false);
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
    final dayBalancer = DayBalancer(
      profile: profile,
      now: _now,
    );
    final dayTasks = allTasks
        .where((task) => _isOnDay(task, today))
        .where(
          (task) =>
              task.status == TaskStatus.pending ||
              task.status == TaskStatus.inProgress,
        )
        .toList(growable: false);
    final todayBalance = await dayBalancer.balance(
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
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowTasks = allTasks
        .where((task) => _isOnDay(task, tomorrow))
        .where(
          (task) =>
              task.status == TaskStatus.pending ||
              task.status == TaskStatus.inProgress,
        )
        .toList(growable: false);
    final tomorrowBalance = await dayBalancer.balance(
      day: tomorrow,
      tasksOfDay: tomorrowTasks,
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
    final proposal = MorningProposal(
      overdueProposals: overdueProposals,
      todayBalance: todayBalance,
      tomorrowBalance: tomorrowBalance,
    );
    return proposal.hasAnything ? proposal : null;
  }
  Future<void> applyProposal(MorningProposal proposal, DateTime today) async {
    for (final overdueProposal in proposal.overdueProposals) {
      if (overdueProposal.proposedSlot != null) {
        final shifted =
            _shiftTask(overdueProposal.task, overdueProposal.proposedSlot!);
        await _tasksDao.updateTask(shifted);
      }
    }
    if (proposal.todayBalance != null) {
      for (final moveOutProposal in proposal.todayBalance!.moveOut) {
        if (moveOutProposal.proposedSlot != null) {
          final shifted =
              _shiftTask(moveOutProposal.task, moveOutProposal.proposedSlot!);
          await _tasksDao.updateTask(shifted);
        }
      }
    }
    if (proposal.tomorrowBalance != null) {
      for (final moveOutProposal in proposal.tomorrowBalance!.moveOut) {
        if (moveOutProposal.proposedSlot != null) {
          final shifted =
              _shiftTask(moveOutProposal.task, moveOutProposal.proposedSlot!);
          await _tasksDao.updateTask(shifted);
        }
      }
    }
    await _settingsDao.setIntValue(
      SettingsKeys.lastMorningRecalculationDate,
      _dateKey(_now()),
    );
  }
  Future<void> _materializeRecurrenceTasks(
    List<Task> tasks,
    DateTime today,
  ) async {
    final templates = await _tasksDao.getRecurrenceTemplates();
    for (final template in templates) {
      final lastInstance = tasks
          .where((t) => t.parentTaskId == template.id)
          .fold<DateTime?>(null, (prev, t) {
        if (t.startAt == null) return prev;
        final taskDate = DateTime.fromMillisecondsSinceEpoch(t.startAt!);
        return prev == null || taskDate.isAfter(prev) ? taskDate : prev;
      });
      final materializeFrom = lastInstance == null
          ? today
          : lastInstance.add(const Duration(days: 1));
      await _recurrenceEngine.materialize(
        templateTask: template,
        startDate: materializeFrom,
        days: 365,
      );
    }
  }
  Future<AIProfile> _loadAiProfile() async {
    final stored = await _aiProfileDao.getProfile();
    if (stored != null) {
      return stored.toDomain();
    }
    return const AIProfile();
  }
  Future<WorkWindow> _loadWorkWindow() async {
    return WorkWindow.fromMinutes(
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
  }
  bool _isOverdue(Task task, DateTime now) {
    if (task.status != TaskStatus.pending) {
      return false;
    }
    if (task.deadlineAt == null) {
      return false;
    }
    return DateTime.fromMillisecondsSinceEpoch(task.deadlineAt!)
        .isBefore(DateTime(now.year, now.month, now.day));
  }
  bool _isOnDay(Task task, DateTime day) {
    if (task.startAt == null) {
      return false;
    }
    final taskDay = DateTime.fromMillisecondsSinceEpoch(task.startAt!);
    return taskDay.year == day.year &&
        taskDay.month == day.month &&
        taskDay.day == day.day;
  }
  Task _shiftTask(Task task, TimeSlot slot) {
    return task.copyWith(
      startAt: drift.Value<int?>(slot.startAt.millisecondsSinceEpoch),
      endAt: drift.Value<int?>(slot.endAt.millisecondsSinceEpoch),
      status: TaskStatus.pending,
      isPinned: false,
    );
  }
  int _dateKey(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }
}

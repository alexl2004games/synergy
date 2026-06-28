import '../../../core/database/app_database.dart';
import '../../../core/llm/domain/ai_profile.dart';
import '../domain/rebalance_proposal.dart';
import '../domain/reschedule_proposal.dart';
import '../domain/work_window.dart';
import 'overdue_rescheduler.dart';
import 'effective_priority_calculator.dart';
class DayBalancer {
  DayBalancer({
    AIProfile profile = const AIProfile(),
    DateTime Function()? now,
  })  : _profile = profile,
        _now = now ?? DateTime.now;
  final AIProfile _profile;
  final DateTime Function() _now;
  final PriorityCalculator _priorityCalculator = PriorityCalculator();
  Future<RebalanceProposal?> balance({
    required DateTime day,
    required List<Task> tasksOfDay,
    required WorkWindow workWindow,
    required AIProfile profile,
    required Future<List<Task>> Function(DateTime day) getTasksForDay,
  }) async {
    final pinnedTasks =
        tasksOfDay.where((task) => task.isPinned).toList(growable: false);
    final nonPinnedTasks =
        tasksOfDay.where((task) => !task.isPinned).toList(growable: false);
    final availableTime =
        workWindow.durationFor(day) - _sumDuration(pinnedTasks);
    final totalLoad = _sumDuration(tasksOfDay);
    if (_sumDuration(nonPinnedTasks) <= availableTime) {
      return null;
    }
    final sorted = [...nonPinnedTasks]..sort((left, right) {
        final leftScore = _priorityCalculator.calculate(left, _now());
        final rightScore = _priorityCalculator.calculate(right, _now());
        return rightScore.compareTo(leftScore);
      });
    final keptTasks = <Task>[];
    final overflowTasks = <Task>[];
    var used = Duration.zero;
    for (final task in sorted) {
      final duration = _taskDuration(task);
      if (used + duration <= availableTime) {
        keptTasks.add(task);
        used += duration;
      } else {
        overflowTasks.add(task);
      }
    }
    final rescheduler = OverdueRescheduler(profile: profile, now: _now);
    final moveOut = <RescheduleProposal>[];
    for (final task in overflowTasks) {
      final proposals = await rescheduler.proposeReschedule(
        overdueTasks: [task],
        startFromDay: day.add(const Duration(days: 1)),
        maxDaysAhead: 14,
        getTasksForDay: getTasksForDay,
        workWindow: workWindow,
        profile: profile,
      );
      moveOut.addAll(proposals);
    }
    return RebalanceProposal(
      moveOut: moveOut,
      totalLoad: totalLoad,
      availableTime: availableTime,
      day: DateTime(day.year, day.month, day.day),
      keptTasks: keptTasks,
      overflowTasks: overflowTasks,
      totalEstimatedMinutes: totalLoad.inMinutes,
      workWindowMinutes: workWindow.durationFor(day).inMinutes,
    );
  }
  Duration _sumDuration(List<Task> tasks) {
    return tasks.fold<Duration>(
      Duration.zero,
      (sum, task) => sum + _taskDuration(task),
    );
  }
  Duration _taskDuration(Task task) {
    if (task.startAt != null &&
        task.endAt != null &&
        task.endAt! > task.startAt!) {
      return Duration(milliseconds: task.endAt! - task.startAt!);
    }
    final adjustedMinutes = (task.estMin * _profile.correctionFactor).round();
    return Duration(minutes: adjustedMinutes);
  }
}

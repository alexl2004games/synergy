import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';
import '../../../core/llm/domain/ai_profile.dart';
import '../../../core/database/tables.dart';
import '../domain/reschedule_proposal.dart';
import '../domain/time_slot.dart';
import '../domain/work_window.dart';
import 'effective_priority_calculator.dart';
import 'slot_finder.dart';
class OverdueRescheduler {
  OverdueRescheduler({
    SlotFinder? slotFinder,
    AIProfile profile = const AIProfile(),
    DateTime Function()? now,
  })  : _slotFinder = slotFinder ?? SlotFinder(),
        _profile = profile,
        _now = now ?? DateTime.now;
  final SlotFinder _slotFinder;
  final AIProfile _profile;
  final DateTime Function() _now;
  final PriorityCalculator _priorityCalculator = PriorityCalculator();
  final List<Task> _manualReviewTasks = [];
  List<Task> get manualReviewTasks =>
      List<Task>.unmodifiable(_manualReviewTasks);
  Future<List<RescheduleProposal>> proposeReschedule({
    required List<Task> overdueTasks,
    required DateTime startFromDay,
    required int maxDaysAhead,
    required Future<List<Task>> Function(DateTime day) getTasksForDay,
    required WorkWindow workWindow,
    required AIProfile profile,
  }) async {
    _manualReviewTasks.clear();
    final candidates = [...overdueTasks]
      ..removeWhere((task) => task.isPinned)
      ..sort((left, right) {
        final leftScore = _priorityCalculator.calculate(left, _now());
        final rightScore = _priorityCalculator.calculate(right, _now());
        return rightScore.compareTo(leftScore);
      });
    final proposals = <RescheduleProposal>[];
    for (final task in candidates) {
      final duration = _taskDuration(task);
      if (duration <= Duration.zero) {
        final proposal = RescheduleProposal(
          task: task,
          proposedSlot: null,
          reason: 'просрочена',
        );
        proposals.add(proposal);
        _manualReviewTasks.add(task);
        continue;
      }
      TimeSlot? slot;
      for (var dayOffset = 0; dayOffset < maxDaysAhead; dayOffset += 1) {
        final day =
            DateTime(startFromDay.year, startFromDay.month, startFromDay.day)
                .add(Duration(days: dayOffset));
        final existingTasks = await getTasksForDay(day);
        slot = _slotFinder.findSlot(
          day: day,
          duration: duration,
          priority: task.priority,
          existingTasks: existingTasks,
          workWindow: workWindow,
          profile: profile,
        );
        if (slot != null) {
          break;
        }
      }
      if (slot == null) {
        proposals.add(
          RescheduleProposal(
            task: task,
            proposedSlot: null,
            reason: 'не удалось вместить',
          ),
        );
        _manualReviewTasks.add(task);
      } else {
        proposals.add(
          RescheduleProposal(
            task: task,
            proposedSlot: slot,
            reason: 'просрочена',
          ),
        );
      }
    }
    return proposals;
  }
  Future<List<Task>> reschedule(List<Task> overdue) async {
    final proposals = await proposeReschedule(
      overdueTasks: overdue,
      startFromDay: DateTime(_now().year, _now().month, _now().day)
          .add(const Duration(days: 1)),
      maxDaysAhead: 14,
      getTasksForDay: (day) async => const <Task>[],
      workWindow: const WorkWindow.defaults(),
      profile: _profile,
    );
    return proposals
        .where((proposal) => proposal.proposedSlot != null)
        .map((proposal) => _shiftTask(proposal.task, proposal.proposedSlot!))
        .toList(growable: false);
  }
  Duration _taskDuration(Task task) {
    final endAt = task.endAt;
    final startAt = task.startAt;
    if (startAt != null && endAt != null && endAt > startAt) {
      return Duration(milliseconds: endAt - startAt);
    }
    if (task.estMin > 0) {
      final adjustedMinutes = (task.estMin * _profile.correctionFactor).round();
      return Duration(minutes: adjustedMinutes);
    }
    return Duration.zero;
  }
  Task _shiftTask(Task task, TimeSlot slot) {
    final duration = _taskDuration(task);
    final endAt = slot.startAt.add(duration);
    final movedBy = slot.startAt.difference(_taskAnchor(task));
    return task.copyWith(
      startAt: drift.Value<int?>(slot.startAt.millisecondsSinceEpoch),
      endAt: drift.Value<int?>(endAt.millisecondsSinceEpoch),
      deadlineAt: task.deadlineAt == null
          ? const drift.Value<int?>(null)
          : drift.Value<int?>(task.deadlineAt! + movedBy.inMilliseconds),
      updatedAt: _now().millisecondsSinceEpoch,
      status: TaskStatus.pending,
    );
  }
  DateTime _taskAnchor(Task task) {
    final startAt = task.startAt;
    if (startAt != null) {
      return DateTime.fromMillisecondsSinceEpoch(startAt);
    }
    final deadlineAt = task.deadlineAt;
    if (deadlineAt != null) {
      return DateTime.fromMillisecondsSinceEpoch(deadlineAt);
    }
    return DateTime.fromMillisecondsSinceEpoch(task.createdAt);
  }
}

import 'dart:math' as math;
import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/llm/domain/ai_profile.dart';
import '../domain/time_slot.dart';
import '../domain/work_window.dart';
class SlotFinder {
  TimeSlot? findSlot({
    required DateTime day,
    required Duration duration,
    required TaskPriority priority,
    required List<Task> existingTasks,
    required WorkWindow workWindow,
    required AIProfile profile,
  }) {
    if (duration <= Duration.zero) {
      return null;
    }
    final dayStart = workWindow.startFor(day);
    final dayEnd = workWindow.endFor(day);
    if (!dayEnd.isAfter(dayStart)) {
      return null;
    }
    final sweepResult = _runSweepLine(dayStart, dayEnd, existingTasks);
    final freeSlots = sweepResult.freeSlots;
    final busySlots = sweepResult.busySlots;
    final candidates = freeSlots
        .where((slot) => slot.duration >= duration)
        .toList(growable: false);
    if (candidates.isEmpty) {
      return null;
    }
    final peakStart =
        DateTime(day.year, day.month, day.day, profile.peakHoursStart);
    final peakEnd =
        DateTime(day.year, day.month, day.day, profile.peakHoursEnd);
    TimeSlot? best;
    var bestScore = double.negativeInfinity;
    for (final free in candidates) {
      final slot = TimeSlot.fromStartAndDuration(
        startAt: free.startAt,
        duration: duration,
      );
      if (slot.endAt.isAfter(free.endAt)) {
        continue;
      }
      final score = _scoreSlot(
        slot: slot,
        peakStart: peakStart,
        peakEnd: peakEnd,
        priority: priority,
        nextBusyStart: _nextBusyStartAfter(slot, busySlots),
        dayEnd: dayEnd,
      );
      if (score > bestScore) {
        bestScore = score;
        best = slot;
      }
    }
    return best;
  }
  _SweepResult _runSweepLine(
    DateTime dayStart,
    DateTime dayEnd,
    List<Task> existingTasks,
  ) {
    final events = <_TimeEvent>[];
    for (final task in existingTasks) {
      if (_isInactive(task) || !task.isPinned) {
        continue;
      }
      final slot = _taskToSlot(task, dayStart, dayEnd);
      if (slot != null) {
        events
          ..add(_TimeEvent(time: slot.startAt, weight: 1))
          ..add(_TimeEvent(time: slot.endAt, weight: -1));
      }
    }
    events.sort();
    final freeSlots = <TimeSlot>[];
    final busySlots = <TimeSlot>[];
    var counter = 0;
    var lastFreeStart = dayStart;
    DateTime? currentBusyStart;
    for (final event in events) {
      if (counter == 0 && event.time.isAfter(lastFreeStart)) {
        freeSlots.add(TimeSlot(startAt: lastFreeStart, endAt: event.time));
      }
      final prevCounter = counter;
      counter += event.weight;
      if (prevCounter == 0 && counter > 0) {
        currentBusyStart = event.time;
      } else if (prevCounter > 0 && counter == 0) {
        if (currentBusyStart != null && event.time.isAfter(currentBusyStart)) {
          busySlots.add(TimeSlot(startAt: currentBusyStart, endAt: event.time));
        }
        currentBusyStart = null;
        lastFreeStart = event.time;
      }
    }
    if (counter == 0 && lastFreeStart.isBefore(dayEnd)) {
      freeSlots.add(TimeSlot(startAt: lastFreeStart, endAt: dayEnd));
    }
    return _SweepResult(freeSlots: freeSlots, busySlots: busySlots);
  }
  double _scoreSlot({
    required TimeSlot slot,
    required DateTime peakStart,
    required DateTime peakEnd,
    required TaskPriority priority,
    required DateTime? nextBusyStart,
    required DateTime dayEnd,
  }) {
    final durationMinutes = math.max(1, slot.duration.inMinutes);
    final overlapMinutes = _overlapMinutes(slot, peakStart, peakEnd);
    final peakScore = overlapMinutes / durationMinutes;
    final morningBonus =
        priority == TaskPriority.high && slot.startAt.hour < 12 ? 0.3 : 0.0;
    final remainderMinutes = nextBusyStart == null
        ? dayEnd.difference(slot.endAt).inMinutes
        : nextBusyStart.difference(slot.endAt).inMinutes;
    final fragmentationPenalty =
        remainderMinutes > 0 && remainderMinutes < 15 ? -0.2 : 0.0;
    return peakScore + morningBonus + fragmentationPenalty;
  }
  int _overlapMinutes(TimeSlot slot, DateTime start, DateTime end) {
    final overlapStart = slot.startAt.isAfter(start) ? slot.startAt : start;
    final overlapEnd = slot.endAt.isBefore(end) ? slot.endAt : end;
    if (!overlapEnd.isAfter(overlapStart)) {
      return 0;
    }
    return overlapEnd.difference(overlapStart).inMinutes;
  }
  DateTime? _nextBusyStartAfter(TimeSlot slot, List<TimeSlot> busySlots) {
    for (final busy in busySlots) {
      if (busy.startAt.isAfter(slot.endAt) ||
          busy.startAt.isAtSameMomentAs(slot.endAt)) {
        return busy.startAt;
      }
    }
    return null;
  }
  TimeSlot? _taskToSlot(Task task, DateTime dayStart, DateTime dayEnd) {
    final startAtMillis = task.startAt;
    if (startAtMillis == null) {
      return null;
    }
    final startAt = DateTime.fromMillisecondsSinceEpoch(startAtMillis);
    final endAtMillis = task.endAt ??
        (startAtMillis + Duration(minutes: task.estMin).inMilliseconds);
    final endAt = DateTime.fromMillisecondsSinceEpoch(endAtMillis);
    final clippedStart = startAt.isBefore(dayStart) ? dayStart : startAt;
    final clippedEnd = endAt.isAfter(dayEnd) ? dayEnd : endAt;
    if (!clippedEnd.isAfter(clippedStart)) {
      return null;
    }
    return TimeSlot(startAt: clippedStart, endAt: clippedEnd);
  }
  bool _isInactive(Task task) {
    return task.status == TaskStatus.cancelled ||
        task.status == TaskStatus.completed;
  }
}
class _TimeEvent implements Comparable<_TimeEvent> {
  const _TimeEvent({required this.time, required this.weight});
  final DateTime time;
  final int weight;
  @override
  int compareTo(_TimeEvent other) {
    final cmp = time.compareTo(other.time);
    if (cmp != 0) {
      return cmp;
    }
    return other.weight.compareTo(weight);
  }
}
class _SweepResult {
  const _SweepResult({
    required this.freeSlots,
    required this.busySlots,
  });
  final List<TimeSlot> freeSlots;
  final List<TimeSlot> busySlots;
}

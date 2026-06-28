import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../domain/time_slot.dart';
class ConflictResolver {
  bool conflictsWithPinned({
    required DateTime start,
    required DateTime end,
    required List<Task> existingTasks,
  }) {
    return getConflictingPinned(
      start: start,
      end: end,
      existingTasks: existingTasks,
    ).isNotEmpty;
  }
  List<Task> getConflictingPinned({
    required DateTime start,
    required DateTime end,
    required List<Task> existingTasks,
  }) {
    final candidate = TimeSlot(startAt: start, endAt: end);
    return existingTasks.where((task) {
      if (!task.isPinned) {
        return false;
      }
      final slot = _taskSlot(task);
      if (slot == null) {
        return false;
      }
      return slot.overlaps(candidate);
    }).toList(growable: false);
  }
  List<Task> getConflictingExactStartTimes({
    required DateTime start,
    required List<Task> existingTasks,
    String? ignoreTaskId,
  }) {
    return existingTasks.where((task) {
      if (task.id == ignoreTaskId) {
        return false;
      }
      if (_isInactive(task) || task.isAllDay) {
        return false;
      }
      final taskStartAt = task.startAt;
      if (taskStartAt == null) {
        return false;
      }
      final taskStart = DateTime.fromMillisecondsSinceEpoch(taskStartAt);
      return taskStart.year == start.year &&
          taskStart.month == start.month &&
          taskStart.day == start.day &&
          taskStart.hour == start.hour &&
          taskStart.minute == start.minute;
    }).toList(growable: false);
  }
  bool hasConflictingExactStartTimes({
    required DateTime start,
    required List<Task> existingTasks,
    String? ignoreTaskId,
  }) {
    return getConflictingExactStartTimes(
      start: start,
      existingTasks: existingTasks,
      ignoreTaskId: ignoreTaskId,
    ).isNotEmpty;
  }
  bool _isInactive(Task task) {
    return task.status == TaskStatus.cancelled ||
        task.status == TaskStatus.completed;
  }
  TimeSlot? _taskSlot(Task task) {
    final startAt = task.startAt;
    if (startAt == null) {
      return null;
    }
    final start = DateTime.fromMillisecondsSinceEpoch(startAt);
    final endAt = task.endAt ?? (startAt + (task.estMin * 60 * 1000));
    final end = DateTime.fromMillisecondsSinceEpoch(endAt);
    if (!end.isAfter(start)) {
      return null;
    }
    return TimeSlot(startAt: start, endAt: end);
  }
}

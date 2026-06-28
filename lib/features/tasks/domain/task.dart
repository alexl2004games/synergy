import 'package:freezed_annotation/freezed_annotation.dart';
part 'task.freezed.dart';
enum TaskStatus {
  pending,
  inProgress,
  completed,
  overdue,
  cancelled,
}
enum TaskPriority {
  low,
  medium,
  high,
}
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String notes,
    DateTime? deadlineAt,
    DateTime? startAt,
    DateTime? endAt,
    @Default(false) bool isAllDay,
    @Default(false) bool isPinned,
    @Default(30) int estMin,
    int? actualMin,
    @Default(TaskStatus.pending) TaskStatus status,
    @Default(TaskPriority.medium) TaskPriority priority,
    @Default(1.0) double aiConfidence,
    String? parentTaskId,
    String? recurrenceRule,
    @Default(false) bool isExceptionOfRule,
    String? exceptionOriginalId,
    DateTime? completedAt,
  }) = _Task;
}

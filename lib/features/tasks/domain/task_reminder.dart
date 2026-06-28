import 'package:freezed_annotation/freezed_annotation.dart';
part 'task_reminder.freezed.dart';
@freezed
abstract class TaskReminder with _$TaskReminder {
  const factory TaskReminder({
    required String id,
    required String taskId,
    required DateTime remindAt,
    @Default(false) bool isSent,
  }) = _TaskReminder;
}

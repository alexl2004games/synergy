import 'package:freezed_annotation/freezed_annotation.dart';
part 'task_checklist_item.freezed.dart';
@freezed
abstract class TaskChecklistItem with _$TaskChecklistItem {
  const factory TaskChecklistItem({
    required String id,
    required String taskId,
    required String title,
    @Default(false) bool isDone,
    @Default(0) int orderIndex,
  }) = _TaskChecklistItem;
}

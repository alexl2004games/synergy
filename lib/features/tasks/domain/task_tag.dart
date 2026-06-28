import 'package:freezed_annotation/freezed_annotation.dart';
part 'task_tag.freezed.dart';
@freezed
abstract class TaskTag with _$TaskTag {
  const factory TaskTag({
    required String id,
    required String taskId,
    required String tagName,
    @Default(false) bool isPrimary,
  }) = _TaskTag;
}

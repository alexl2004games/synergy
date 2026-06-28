import 'package:flutter/material.dart';
import '../../domain/task.dart';
import '../new_task_bottom_sheet.dart';
import '../providers/task_creation_controller.dart';
class TaskFormSheet {
  const TaskFormSheet._();
  static void show(
    BuildContext context, {
    Task? task,
    bool isToday = false,
    bool forceBypassLlm = false,
    String? initialTitle,
    Future<void> Function(TaskCreationRequest request)? onSubmit,
  }) {
    NewTaskBottomSheet.show(
      context,
      task: task,
      isToday: isToday,
      forceBypassLlm: forceBypassLlm,
      initialTitle: initialTitle,
      onSubmit: onSubmit,
    );
  }
}

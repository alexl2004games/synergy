import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/application/notification_providers.dart';
import '../../../recurrence/application/recurrence_engine_provider.dart';
import '../../../recurrence/presentation/delete_recurrence_dialog.dart';
import '../../../scheduling/application/task_scheduling_refresh_trigger.dart';
import '../../application/task_repository_provider.dart';
import '../../data/drift_task_repository.dart';
import '../../domain/task.dart';
import 'task_card.dart';
class TaskSwipeItem extends ConsumerWidget {
  const TaskSwipeItem({required this.task, super.key});
  final Task task;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(taskRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(task.id),
        background: const _SwipeBackground(
          icon: Icons.check_circle_outline,
          alignment: Alignment.centerLeft,
          color: Colors.green,
        ),
        secondaryBackground: const _SwipeBackground(
          icon: Icons.delete_outline,
          alignment: Alignment.centerRight,
          color: Colors.red,
        ),
        confirmDismiss: (direction) async {
          switch (direction) {
            case DismissDirection.startToEnd:
              await repo.update(
                task.copyWith(
                  status: TaskStatus.completed,
                  completedAt: DateTime.now(),
                ),
              );
              await ref.read(notificationServiceProvider).cancelTaskReminder(
                    task.id,
                  );
              return true;
            case DismissDirection.endToStart:
              final recurring = (task.recurrenceRule?.isNotEmpty ?? false) ||
                  task.parentTaskId != null;
              if (!recurring) {
                await repo.delete(task.id);
                await ref.read(notificationServiceProvider).cancelTaskReminder(
                      task.id,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.taskDeletedSnack,
                        ),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context)!.undoButton,
                          onPressed: () {
                            unawaited(repo.save(task));
                            unawaited(
                              ref
                                  .read(notificationServiceProvider)
                                  .scheduleTaskReminder(task, 15),
                            );
                          },
                        ),
                      ),
                    );
                }
                return true;
              }
              final choice = await showDialog<DeleteRecurrenceOption>(
                context: context,
                builder: (_) => const DeleteRecurrenceDialog(),
              );
              if (choice == null) {
                return false;
              }
              final recurrenceEngine = ref.read(recurrenceEngineProvider);
              final driftTask = task.toDrift();
              switch (choice) {
                case DeleteRecurrenceOption.instance:
                  await recurrenceEngine.deleteAllExceptInstance(driftTask);
                case DeleteRecurrenceOption.allFuture:
                  await recurrenceEngine.deleteAllFuture(driftTask);
                case DeleteRecurrenceOption.all:
                  await recurrenceEngine.deleteSeries(driftTask);
              }
              ref.read(taskSchedulingRefreshTriggerProvider).schedule();
              await ref.read(notificationServiceProvider).cancelTaskReminder(
                    task.id,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.taskDeletedSnack,
                      ),
                    ),
                  );
              }
              return true;
            case DismissDirection.horizontal:
            case DismissDirection.vertical:
            case DismissDirection.up:
            case DismissDirection.down:
            case DismissDirection.none:
              return false;
          }
        },
        child: TaskCard(
          task: task,
          onTap: () => context.push('/task/${task.id}'),
        ),
      ),
    );
  }
}
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.icon,
    required this.alignment,
    required this.color,
  });
  final IconData icon;
  final Alignment alignment;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

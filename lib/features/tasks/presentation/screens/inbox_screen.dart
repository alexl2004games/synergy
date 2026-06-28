import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/application/notification_providers.dart';
import '../../application/task_repository_provider.dart';
import '../../data/drift_task_repository.dart';
import '../../domain/task.dart';
import '../../../scheduling/application/task_scheduling_refresh_trigger.dart';
import '../../../recurrence/application/recurrence_engine_provider.dart';
import '../../../recurrence/presentation/delete_recurrence_dialog.dart';
import '../providers/task_creation_controller.dart';
import '../providers/tasks_provider.dart';
import '../widgets/task_card.dart';
import '../../../../core/widgets/floating_action_double_button.dart';
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tasksAsync = ref.watch(inboxTasksProvider);
    ref.listen(taskCreationControllerProvider, (previous, next) {
      if (!next.hasError || !context.mounted) {
        return;
      }
      final message = next.error is TaskCreationConflictException
          ? l10n.taskConflictBody
          : next.error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.inbox),
        actions: [
          IconButton(
            tooltip: l10n.searchTitle,
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final withDeadline = tasks
              .where((task) => task.deadlineAt != null && task.startAt == null)
              .toList(growable: false);
          final withoutDate = tasks
              .where((task) => task.deadlineAt == null && task.startAt == null)
              .toList(growable: false);
          if (withDeadline.isEmpty && withoutDate.isEmpty) {
            return _EmptyState(
              icon: Icons.inbox_outlined,
              title: l10n.inboxEmptyTitle,
              body: l10n.inboxEmptyBody,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (withDeadline.isNotEmpty) ...[
                _InboxSection(
                  title: l10n.inboxDeadlineSectionTitle,
                  tasks: withDeadline,
                ),
                if (withoutDate.isNotEmpty) const SizedBox(height: 20),
              ],
              if (withoutDate.isNotEmpty)
                _InboxSection(
                  title: l10n.inboxNoDateSectionTitle,
                  tasks: withoutDate,
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
      floatingActionButton: const FloatingActionDoubleButton(
        forceBypassLlm: true,
      ),
    );
  }
}
class _InboxSection extends StatelessWidget {
  const _InboxSection({required this.title, required this.tasks});
  final String title;
  final List<Task> tasks;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...tasks.expand(
          (task) => [
            _TaskSwipeItem(task: task),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }
}
class _TaskSwipeItem extends ConsumerWidget {
  const _TaskSwipeItem({required this.task});
  final Task task;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(taskRepositoryProvider);
    return Dismissible(
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
            return false;
          case DismissDirection.vertical:
            return false;
          case DismissDirection.up:
            return false;
          case DismissDirection.down:
            return false;
          case DismissDirection.none:
            return false;
        }
      },
      child: TaskCard(
        task: task,
        onTap: () => context.push('/task/${task.id}'),
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }
}
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

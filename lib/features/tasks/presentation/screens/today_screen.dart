import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/floating_action_double_button.dart';
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
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(todayTasksProvider);
    final hasCheckIn = ref.watch(todayCheckInDoneProvider).value ?? false;
    final isLateWithoutCheckIn = !hasCheckIn && DateTime.now().hour >= 18;
    ref
      ..listen(taskCreationControllerProvider, (previous, next) {
        if (next.hasError && context.mounted) {
          final message = next.error is TaskCreationConflictException
              ? l10n.taskConflictBody
              : next.error.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      })
      ..listen<AsyncValue<List<Task>>>(todayTasksProvider, (previous, next) {
        if (previous == null || !previous.hasValue || !next.hasValue) {
          return;
        }
        final prevTasks = previous.value!;
        final nextTasks = next.value!;
        final prevPending = prevTasks
            .where((t) => t.status != TaskStatus.completed)
            .toList(growable: false);
        final nextPending = nextTasks
            .where((t) => t.status != TaskStatus.completed)
            .toList(growable: false);
        final nextCompleted = nextTasks
            .where((t) => t.status == TaskStatus.completed)
            .toList(growable: false);
        if (prevPending.isNotEmpty &&
            nextPending.isEmpty &&
            nextCompleted.isNotEmpty) {
          ref.read<ConfettiNotifier>(confettiProvider.notifier).play();
        }
      });
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.today),
        actions: [
          IconButton(
            tooltip: l10n.searchTitle,
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: l10n.todayCheckinTooltip,
            onPressed: () => context.push('/checkin'),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.mood_outlined,
                  color: hasCheckIn
                      ? theme.colorScheme.outline
                      : theme.colorScheme.onSurfaceVariant,
                ),
                if (isLateWithoutCheckIn)
                  const Positioned(
                    right: -1,
                    top: -1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 8, height: 8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          tasksAsync.when(
            data: (tasks) => _TodayTaskList(
              tasks: tasks,
              emptyTitle: l10n.todayEmptyTitle,
              emptyBody: l10n.todayEmptyBody,
              scheduledTitle: l10n.todayScheduledGroupTitle,
              allDayTitle: l10n.todayAllDayGroupTitle,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
          ),
        ],
      ),
      floatingActionButton: const FloatingActionDoubleButton(
        isToday: true,
      ),
    );
  }
}
class _GemmaWorkingOverlay extends StatefulWidget {
  const _GemmaWorkingOverlay();
  @override
  State<_GemmaWorkingOverlay> createState() => _GemmaWorkingOverlayState();
}
class _GemmaWorkingOverlayState extends State<_GemmaWorkingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final breath = math.sin(_controller.value * 2 * math.pi);
                  final breathScale = 0.95 + (breath * 0.05);
                  final rotation = _controller.value * 2 * math.pi;
                  return GlassContainer(
                    borderRadius: 24,
                    blur: 24,
                    bgOpacity: isDark ? 0.25 : 0.12,
                    borderOpacity: isDark ? 0.15 : 0.22,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 36,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: breathScale * 1.15,
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withValues(
                                          alpha: 0.25 * (0.6 + 0.4 * breath),
                                        ),
                                        blurRadius: 45 + (15 * breath),
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.purpleAccent.withValues(
                                          alpha: 0.25 *
                                              (0.6 +
                                                  0.4 *
                                                      math.cos(
                                                        _controller.value *
                                                            2 *
                                                            math.pi,
                                                      )),
                                        ),
                                        blurRadius: 55 - (15 * breath),
                                        spreadRadius: -2,
                                      ),
                                    ],
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.cyan.withValues(alpha: 0.0),
                                        Colors.cyan.withValues(alpha: 0.05),
                                        Colors.purpleAccent.withValues(
                                          alpha: 0.15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: breathScale,
                                child: Transform.rotate(
                                  angle: rotation,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: SweepGradient(
                                        colors: [
                                          Colors.cyanAccent.withValues(
                                            alpha: 0.65,
                                          ),
                                          Colors.purpleAccent.withValues(
                                            alpha: 0.75,
                                          ),
                                          Colors.blueAccent.withValues(
                                            alpha: 0.55,
                                          ),
                                          Colors.cyanAccent.withValues(
                                            alpha: 0.65,
                                          ),
                                        ],
                                        stops: const [0.0, 0.35, 0.7, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isDark ? Colors.black : Colors.white)
                                      .withValues(alpha: 0.25),
                                  border: Border.all(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.92 +
                                    (0.08 *
                                        math.sin(
                                          _controller.value * 4 * math.pi,
                                        )),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.cyanAccent.withValues(
                                          alpha: 0.8,
                                        ),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.45, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Opacity(
                          opacity: 0.75 + (0.25 * breath),
                          child: Text(
                            AppLocalizations.of(context)!.aiProcessingTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: 0.5,
                              shadows: isDark
                                  ? [
                                      Shadow(
                                        color: Colors.cyanAccent.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.aiProcessingSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.85),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _TodayTaskList extends StatefulWidget {
  const _TodayTaskList({
    required this.tasks,
    required this.emptyTitle,
    required this.emptyBody,
    required this.scheduledTitle,
    required this.allDayTitle,
  });
  final List<Task> tasks;
  final String emptyTitle;
  final String emptyBody;
  final String scheduledTitle;
  final String allDayTitle;
  @override
  State<_TodayTaskList> createState() => _TodayTaskListState();
}
class _TodayTaskListState extends State<_TodayTaskList> {
  bool _completedExpanded = false;
  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.75,
            child: _EmptyState(
              icon: Icons.free_breakfast_outlined,
              title: widget.emptyTitle,
              body: widget.emptyBody,
            ),
          ),
        ],
      );
    }
    final pending = widget.tasks
        .where((t) => t.status != TaskStatus.completed)
        .toList(growable: false);
    final completed = widget.tasks
        .where((t) => t.status == TaskStatus.completed)
        .toList(growable: false);
    final scheduled = pending.where(_isTimedTask).toList(growable: false)
      ..sort(_compareByStartTime);
    final dayBound = pending.where(_isDayBoundTask).toList(growable: false)
      ..sort(_compareByPriority);
    if (scheduled.isEmpty && dayBound.isEmpty && completed.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.75,
            child: _EmptyState(
              icon: Icons.free_breakfast_outlined,
              title: widget.emptyTitle,
              body: widget.emptyBody,
            ),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (scheduled.isNotEmpty) ...[
          _SectionTitle(title: widget.scheduledTitle),
          const SizedBox(height: 8),
          ...scheduled.map((task) => _TaskSwipeItem(task: task)),
          const SizedBox(height: 20),
        ],
        if (dayBound.isNotEmpty) ...[
          _SectionTitle(title: widget.allDayTitle),
          const SizedBox(height: 8),
          ...dayBound.map((task) => _TaskSwipeItem(task: task)),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 20),
          _CompletedSection(
            tasks: completed,
            isExpanded: _completedExpanded,
            onExpandedChanged: (expanded) {
              setState(() => _completedExpanded = expanded);
            },
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
      ),
    );
  }
}
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
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
class _CompletedSection extends StatelessWidget {
  const _CompletedSection({
    required this.tasks,
    required this.isExpanded,
    required this.onExpandedChanged,
  });
  final List<Task> tasks;
  final bool isExpanded;
  final ValueChanged<bool> onExpandedChanged;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        '${AppLocalizations.of(context)!.taskCompleted} (${tasks.length})',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: onExpandedChanged,
      trailing: Icon(
        isExpanded ? Icons.expand_less : Icons.expand_more,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: tasks
          .map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Opacity(
                opacity: 0.6,
                child: TaskCard(
                  task: task,
                  onTap: () => context.push('/task/${task.id}'),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
bool _isTimedTask(Task task) => task.startAt != null && !_isDayBoundTask(task);
bool _isDayBoundTask(Task task) {
  if (task.isAllDay) {
    return true;
  }
  if (task.startAt == null && task.deadlineAt != null) {
    return true;
  }
  final startAt = task.startAt;
  if (startAt == null || task.endAt != null) {
    return false;
  }
  return startAt.hour == 0 && startAt.minute == 0 && startAt.second == 0;
}
int _compareByStartTime(Task first, Task second) {
  return first.startAt!.compareTo(second.startAt!);
}
int _compareByPriority(Task first, Task second) {
  return _priorityValue(second.priority)
      .compareTo(_priorityValue(first.priority));
}
int _priorityValue(TaskPriority priority) {
  return switch (priority) {
    TaskPriority.high => 3,
    TaskPriority.medium => 2,
    TaskPriority.low => 1,
  };
}

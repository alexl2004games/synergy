import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/application/notification_providers.dart';
import '../../../scheduling/application/task_scheduling_refresh_trigger.dart';
import '../../../recurrence/application/recurrence_engine_provider.dart';
import '../../../recurrence/presentation/delete_recurrence_dialog.dart';
import '../../application/task_repository_provider.dart';
import '../../data/drift_task_repository.dart';
import '../../domain/task.dart';
import '../providers/task_views_provider.dart';
import '../widgets/task_card.dart';
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}
class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateUtils.dateOnly(DateTime.now());
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());
  double _scale = 1.0;
  double _baseScale = 1.0;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final tasksAsync = ref.watch(allTasksProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.calendarTab),
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
          final startingDayOfWeek = locale.languageCode == 'ru'
              ? StartingDayOfWeek.monday
              : StartingDayOfWeek.sunday;
          return LayoutBuilder(
            builder: (context, constraints) {
              const headerHeight = 56.0;
              final daysOfWeekHeight = 24.0 * _scale;
              final availableHeight =
                  constraints.maxHeight - headerHeight - daysOfWeekHeight - 32;
              final calculatedRowHeight =
                  (availableHeight / 6.0).clamp(52.0, 160.0);
              final rowHeight = calculatedRowHeight * _scale;
              return GestureDetector(
                onScaleStart: (details) {
                  _baseScale = _scale;
                },
                onScaleUpdate: (details) {
                  if (details.pointerCount >= 2) {
                    setState(() {
                      _scale = (_baseScale * details.scale).clamp(0.6, 2.5);
                    });
                  }
                },
                child: SingleChildScrollView(
                  child: TableCalendar<Task>(
                    locale: locale.toLanguageTag(),
                    firstDay: DateTime.utc(DateTime.now().year - 1),
                    lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
                    focusedDay: _focusedDay,
                    startingDayOfWeek: startingDayOfWeek,
                    availableGestures: AvailableGestures.horizontalSwipe,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) => _tasksForDay(tasks, day),
                    rowHeight: rowHeight,
                    daysOfWeekHeight: daysOfWeekHeight,
                    onDaySelected: (selectedDay, focusedDay) async {
                      setState(() {
                        _selectedDay = DateUtils.dateOnly(selectedDay);
                        _focusedDay = DateUtils.dateOnly(focusedDay);
                      });
                      await _showTasksForDay(context, _selectedDay, tasks);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = DateUtils.dateOnly(focusedDay);
                      });
                    },
                    calendarBuilders: CalendarBuilders<Task>(
                      markerBuilder: (context, day, events) =>
                          const SizedBox.shrink(),
                      todayBuilder: (context, day, focusedDay) => _buildDayCell(
                        context,
                        day,
                        tasks,
                        isToday: true,
                        isSelected: isSameDay(_selectedDay, day),
                        isOutside: false,
                      ),
                      selectedBuilder: (context, day, focusedDay) =>
                          _buildDayCell(
                        context,
                        day,
                        tasks,
                        isToday: isSameDay(DateTime.now(), day),
                        isSelected: true,
                        isOutside: false,
                      ),
                      defaultBuilder: (context, day, focusedDay) =>
                          _buildDayCell(
                        context,
                        day,
                        tasks,
                        isToday: isSameDay(DateTime.now(), day),
                        isSelected: isSameDay(_selectedDay, day),
                        isOutside: false,
                      ),
                      outsideBuilder: (context, day, focusedDay) =>
                          _buildDayCell(
                        context,
                        day,
                        tasks,
                        isToday: isSameDay(DateTime.now(), day),
                        isSelected: isSameDay(_selectedDay, day),
                        isOutside: true,
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(),
                      selectedDecoration: BoxDecoration(),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
      ),
    );
  }
  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    List<Task> allTasks, {
    required bool isToday,
    required bool isSelected,
    required bool isOutside,
  }) {
    final dayEvents = _tasksForDay(allTasks, day);
    final theme = Theme.of(context);
    if (_scale >= 1.4) {
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : isToday
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.6)
                : isToday
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.08),
            width: isSelected || isToday ? 1.5 : 0.5,
          ),
        ),
        padding: const EdgeInsets.all(3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: isToday
                  ? BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 10 * _scale,
                  fontWeight: isToday || isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isToday
                      ? theme.colorScheme.onPrimary
                      : isOutside
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: dayEvents.take(3).map((task) {
                  final priorityColor =
                      _taskPriorityColor(task, theme.colorScheme);
                  final isCompleted = task.status == TaskStatus.completed;
                  return Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: priorityColor.withValues(alpha: 0.35),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isCompleted)
                          Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 7 * _scale,
                              color: Colors.green,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8.0 * _scale,
                              fontWeight: FontWeight.w500,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(1),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28 * _scale,
              height: 28 * _scale,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isToday
                        ? theme.colorScheme.primaryContainer
                        : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 13 * _scale,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : isToday
                          ? theme.colorScheme.onPrimaryContainer
                          : isOutside
                              ? theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3)
                              : theme.colorScheme.onSurface,
                  fontWeight: isToday || isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            if (dayEvents.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dayEvents.take(3).map((task) {
                  return Container(
                    width: 4 * _scale,
                    height: 4 * _scale,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: _taskPriorityColor(task, theme.colorScheme),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      );
    }
  }
  List<Task> _tasksForDay(List<Task> tasks, DateTime day) {
    final dayKey = DateUtils.dateOnly(day);
    final today = DateUtils.dateOnly(DateTime.now());
    return tasks.where((task) {
      final startAt = task.startAt;
      final deadlineAt = task.deadlineAt;
      if (startAt != null) {
        final taskDay = DateUtils.dateOnly(startAt);
        if (deadlineAt != null) {
          final deadlineDay = DateUtils.dateOnly(deadlineAt);
          if (taskDay.isAfter(deadlineDay)) {
            return dayKey == taskDay;
          }
          return dayKey == taskDay || dayKey == deadlineDay;
        }
        return taskDay == dayKey;
      }
      if (deadlineAt != null) {
        final deadlineDay = DateUtils.dateOnly(deadlineAt);
        return dayKey == deadlineDay || dayKey == today;
      }
      return false;
    }).toList(growable: false);
  }
  Color _taskPriorityColor(Task task, ColorScheme colorScheme) {
    if (task.status == TaskStatus.completed) {
      return Colors.green;
    }
    if (task.deadlineAt != null) {
      return Colors.amber;
    }
    switch (task.priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return colorScheme.primary;
      case TaskPriority.low:
        return Colors.blue;
    }
  }
  Future<void> _showTasksForDay(
    BuildContext context,
    DateTime day,
    List<Task> tasks,
  ) async {
    final outerContext = context;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final title =
            MaterialLocalizations.of(sheetContext).formatFullDate(day);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.75,
              child: Consumer(
                builder: (context, ref, child) {
                  final allTasks =
                      ref.watch(allTasksProvider).value ?? const [];
                  final visibleTasks = _tasksForDay(allTasks, day);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: visibleTasks.isEmpty
                            ? _EmptyState(
                                title: AppLocalizations.of(context)!
                                    .calendarEmptyTitle,
                                body: AppLocalizations.of(context)!
                                    .calendarEmptyBody,
                              )
                            : ListView.separated(
                                itemBuilder: (context, index) {
                                  final task = visibleTasks[index];
                                  return _DismissibleTaskCard(
                                    task: task,
                                    onDeleted: () {
                                    },
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      outerContext.push('/task/${task.id}');
                                    },
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemCount: visibleTasks.length,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
class _DismissibleTaskCard extends ConsumerWidget {
  const _DismissibleTaskCard({
    required this.task,
    required this.onDeleted,
    required this.onTap,
  });
  final Task task;
  final VoidCallback onDeleted;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.check_circle_outline, color: Colors.green),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      confirmDismiss: (direction) async {
        switch (direction) {
          case DismissDirection.startToEnd:
            await ref.read(taskRepositoryProvider).update(
                  task.copyWith(
                    status: TaskStatus.completed,
                    completedAt: DateTime.now(),
                  ),
                );
            await ref
                .read(notificationServiceProvider)
                .cancelTaskReminder(task.id);
            return true;
          case DismissDirection.endToStart:
            final recurring = (task.recurrenceRule?.isNotEmpty ?? false) ||
                task.parentTaskId != null;
            if (!recurring) {
              await ref.read(taskRepositoryProvider).delete(task.id);
              await ref
                  .read(notificationServiceProvider)
                  .cancelTaskReminder(task.id);
              onDeleted();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.taskDeletedSnack),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)!.undoButton,
                      onPressed: () {
                        unawaited(ref.read(taskRepositoryProvider).save(task));
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
            await ref
                .read(notificationServiceProvider)
                .cancelTaskReminder(task.id);
            onDeleted();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.taskDeletedSnack),
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
        onTap: onTap,
      ),
    );
  }
}

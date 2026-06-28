import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/task.dart';
import '../providers/tasks_provider.dart';
import '../../application/task_repository_provider.dart';
class TaskCard extends ConsumerWidget {
  const TaskCard({required this.task, this.onTap, super.key});
  final Task task;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tagsAsync = ref.watch(taskTagsByTaskIdProvider(task.id));
    final locale = Localizations.localeOf(context).toLanguageTag();
    String? timeText;
    var showDurationIcon = false;
    String? durationText;
    if (task.isAllDay) {
      timeText = l10n.taskAllDayLabel;
    } else if (_visibleTime(task)) {
      final start = task.startAt!;
      var end = task.endAt;
      if (end == null && task.estMin > 0) {
        end = start.add(Duration(minutes: task.estMin));
      }
      final startStr = DateFormat.Hm(locale).format(start);
      if (end != null) {
        final endStr = DateFormat.Hm(locale).format(end);
        timeText = '$startStr – $endStr';
      } else {
        timeText = startStr;
        if (task.estMin > 0) {
          showDurationIcon = true;
          durationText = '${task.estMin}m';
        }
      }
    } else if (task.startAt == null && task.deadlineAt != null) {
      final dl = task.deadlineAt!;
      final hasTime = !(dl.hour == 0 && dl.minute == 0 && dl.second == 0);
      if (hasTime) {
        final dlStr = DateFormat.Hm(locale).format(dl);
        timeText = 'до $dlStr';
      } else {
        timeText = null;
      }
    } else {
      timeText = null;
    }
    final deadlineText = task.deadlineAt == null
        ? null
        : _formatDeadline(task.deadlineAt!, locale);
    final priorityText = _priorityLabel(l10n, task.priority);
    final priorityColor = _priorityColor(task.priority, theme.colorScheme);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark
          ? Colors.black.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TaskCardCheckbox(
                isCompleted: task.status == TaskStatus.completed,
                onChanged: (value) async {
                  final repo = ref.read(taskRepositoryProvider);
                  final isCompleted = value;
                  if (isCompleted) {
                    unawaited(HapticFeedback.heavyImpact());
                  } else {
                    unawaited(HapticFeedback.lightImpact());
                  }
                  final updated = task.copyWith(
                    status:
                        isCompleted ? TaskStatus.completed : TaskStatus.pending,
                    completedAt: isCompleted ? DateTime.now() : null,
                  );
                  await repo.update(updated);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (deadlineText != null ||
                            task.isAllDay ||
                            _isRecurring(task) ||
                            task.isPinned) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (deadlineText != null)
                                Tooltip(
                                  message: deadlineText,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        deadlineText,
                                        style: theme.textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              if (task.isAllDay)
                                const Icon(Icons.event_available, size: 16),
                              if (_isRecurring(task))
                                const Icon(
                                  Icons.repeat,
                                  size: 16,
                                  color: Colors.deepPurple,
                                ),
                              if (task.isPinned)
                                const Icon(Icons.lock_outline, size: 18),
                            ],
                          ),
                        ],
                      ],
                    ),
                    if (task.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.notes,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    tagsAsync.when(
                      data: (tags) {
                        if (tags.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tags
                                .take(3)
                                .map(
                                  (tag) => Chip(
                                    label: Text(tag.tagName),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (timeText != null)
                    Text(timeText, style: theme.textTheme.labelLarge),
                  if (showDurationIcon && durationText != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          durationText,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  if (timeText != null && showDurationIcon)
                    const SizedBox(height: 2),
                  Text(
                    priorityText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: priorityColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
bool _visibleTime(Task task) {
  if (task.startAt == null || task.isAllDay) {
    return false;
  }
  return !(task.startAt!.hour == 0 &&
      task.startAt!.minute == 0 &&
      task.startAt!.second == 0);
}
bool _isRecurring(Task task) {
  return (task.recurrenceRule?.isNotEmpty ?? false) ||
      task.parentTaskId != null;
}
String _formatDeadline(DateTime deadlineAt, String locale) {
  final nowYear = DateTime.now().year;
  final hasTime = !(deadlineAt.hour == 0 &&
      deadlineAt.minute == 0 &&
      deadlineAt.second == 0);
  if (hasTime) {
    final pattern =
        deadlineAt.year == nowYear ? 'd MMM, HH:mm' : 'd MMM y, HH:mm';
    return DateFormat(pattern, locale).format(deadlineAt);
  } else {
    final pattern = deadlineAt.year == nowYear ? 'd MMM' : 'd MMM y';
    return DateFormat(pattern, locale).format(deadlineAt);
  }
}
String _priorityLabel(AppLocalizations l10n, TaskPriority priority) {
  return switch (priority) {
    TaskPriority.low => l10n.taskPriorityLowLabel,
    TaskPriority.medium => l10n.taskPriorityMediumLabel,
    TaskPriority.high => l10n.taskPriorityHighLabel,
  };
}
Color _priorityColor(TaskPriority priority, ColorScheme colorScheme) {
  return switch (priority) {
    TaskPriority.low => colorScheme.outline,
    TaskPriority.medium => colorScheme.primary,
    TaskPriority.high => colorScheme.error,
  };
}
class _TaskCardCheckbox extends StatefulWidget {
  const _TaskCardCheckbox({
    required this.isCompleted,
    required this.onChanged,
  });
  final bool isCompleted;
  final ValueChanged<bool> onChanged;
  @override
  State<_TaskCardCheckbox> createState() => _TaskCardCheckboxState();
}
class _TaskCardCheckboxState extends State<_TaskCardCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.1), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = widget.isCompleted;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _controller.forward(from: 0.0);
          widget.onChanged(!isDone);
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isDone
                  ? null
                  : Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      width: 1.6,
                    ),
              gradient: isDone
                  ? LinearGradient(
                      colors: [
                        Colors.cyanAccent.withValues(alpha: 0.9),
                        Colors.purpleAccent.withValues(alpha: 0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow: isDone
                  ? [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isDone
                ? const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

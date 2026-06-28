import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/domain/settings_keys.dart'
    as notification_settings_keys;
import '../../../../core/providers/database_provider.dart';
import '../../../../core/notifications/application/notification_providers.dart';
import '../../application/task_repository_provider.dart';
import '../../data/drift_task_repository.dart';
import '../../domain/task.dart';
import '../../domain/task_checklist_item.dart';
import '../providers/tasks_provider.dart';
import '../widgets/expandable_section.dart';
import '../../../scheduling/application/conflict_resolver.dart';
import '../../../scheduling/application/task_scheduling_refresh_trigger.dart';
import '../../../recurrence/application/recurrence_engine_provider.dart';
import '../../../recurrence/presentation/recurrence_editor_dialog.dart';
import '../widgets/duration_input_field.dart';
class TaskDetailsScreen extends ConsumerStatefulWidget {
  const TaskDetailsScreen({required this.taskId, super.key});
  final String taskId;
  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}
class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _checklistController;
  final ConflictResolver _conflictResolver = ConflictResolver();
  String? _loadedTaskId;
  bool? _isPinned;
  String? _recurrenceRule;
  DateTime? _selectedDate;
  DateTime? _selectedStartTime;
  DateTime? _selectedDeadline;
  int _estMin = 30;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    _checklistController = TextEditingController();
  }
  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _checklistController.dispose();
    super.dispose();
  }
  void _syncControllers(Task task) {
    if (_loadedTaskId == task.id) {
      return;
    }
    _loadedTaskId = task.id;
    _titleController.text = task.title;
    _notesController.text = task.notes;
    _isPinned = task.isPinned;
    _recurrenceRule = task.recurrenceRule;
    _selectedDeadline = task.deadlineAt;
    _selectedDate = task.startAt;
    _selectedStartTime = task.isAllDay ? null : task.startAt;
    _estMin = task.estMin;
  }
  Future<void> _saveTask(Task task) async {
    final startAt = _composeStartAt(task);
    final isAllDay = _selectedDate != null && _selectedStartTime == null;
    if (startAt != null && !isAllDay) {
      final conflicts = _conflictResolver.getConflictingExactStartTimes(
        start: startAt,
        existingTasks: await ref.read(tasksDaoProvider).getAllTasks(),
        ignoreTaskId: task.id,
      );
      if (conflicts.isNotEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('На это время уже есть задача. Выберите другое время.'),
          ),
        );
        return;
      }
    }
    final updated = task.copyWith(
      title: _titleController.text.trim(),
      notes: _notesController.text.trim(),
      isPinned: _isPinned ?? task.isPinned,
      recurrenceRule: _recurrenceRule,
      startAt: startAt,
      endAt: _composeEndAt(startAt, isAllDay, _estMin),
      deadlineAt: _selectedDeadline,
      isAllDay: isAllDay,
      estMin: _estMin,
      updatedAt: DateTime.now(),
    );
    await ref.read(taskRepositoryProvider).update(updated);
    await _syncTaskReminder(updated);
    ref.read(taskSchedulingRefreshTriggerProvider).schedule();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.taskDetailsSaved)),
    );
  }
  Future<void> _addChecklistItem(Task task) async {
    final title = _checklistController.text.trim();
    if (title.isEmpty) {
      return;
    }
    final existing =
        await ref.read(checklistRepositoryProvider).getByTaskId(task.id);
    final normalized = title.toLowerCase();
    final isDuplicate =
        existing.any((item) => item.title.toLowerCase() == normalized);
    if (isDuplicate) {
      _checklistController.clear();
      return;
    }
    await ref.read(checklistRepositoryProvider).save(
          TaskChecklistItem(
            id: const Uuid().v4(),
            taskId: task.id,
            title: title,
            orderIndex: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    _checklistController.clear();
    ref.invalidate(checklistByTaskIdProvider(task.id));
  }
  Future<void> _toggleChecklistItem(
    TaskChecklistItem item,
    bool value,
  ) async {
    await ref.read(checklistRepositoryProvider).update(
          item.copyWith(isDone: value),
        );
    ref.invalidate(checklistByTaskIdProvider(item.taskId));
  }
  Future<void> _deleteChecklistItem(String id, String taskId) async {
    await ref.read(checklistRepositoryProvider).delete(id);
    ref.invalidate(checklistByTaskIdProvider(taskId));
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final taskAsync = ref.watch(taskByIdProvider(widget.taskId));
    final checklistAsync = ref.watch(checklistByTaskIdProvider(widget.taskId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.taskDetailsTitle),
      ),
      body: taskAsync.when(
        data: (task) {
          if (task == null) {
            return Center(child: Text(l10n.taskDetailsNotFound));
          }
          _syncControllers(task);
          return checklistAsync.when(
            data: (items) {
              final sortedItems = [...items]
                ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.taskDetailsTitleLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.taskChecklistSectionTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.8),
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _checklistController,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: l10n.taskChecklistAddLabel,
                      prefixIcon: const Icon(Icons.add_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.playlist_add_rounded),
                        onPressed: () => _addChecklistItem(task),
                      ),
                    ),
                    onSubmitted: (_) => _addChecklistItem(task),
                  ),
                  if (sortedItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...sortedItems.map(
                      (item) => _PremiumChecklistItem(
                        item: item,
                        onToggle: (value) {
                          unawaited(_toggleChecklistItem(item, value));
                        },
                        onDelete: () {
                          unawaited(
                            _deleteChecklistItem(item.id, item.taskId),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ExpandableSection(
                    title: l10n.taskNotesSectionTitle,
                    initiallyExpanded: true,
                    children: [
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: l10n.taskDetailsNotesLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ExpandableSection(
                    title: '⏰ Сроки и расписание',
                    children: [
                      _ScheduleTile(
                        icon: Icons.calendar_today,
                        label: 'Дата',
                        value: _selectedDate == null
                            ? 'Не выбрана'
                            : DateFormat.yMMMd(
                                Localizations.localeOf(context).toLanguageTag(),
                              ).format(_selectedDate!),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        onClear: _selectedDate == null
                            ? null
                            : () => setState(() => _selectedDate = null),
                      ),
                      const SizedBox(height: 8),
                      _ScheduleTile(
                        icon: Icons.schedule,
                        label: 'Время',
                        value: _selectedStartTime == null
                            ? 'Не выбрано'
                            : DateFormat.Hm(
                                Localizations.localeOf(context).toLanguageTag(),
                              ).format(_selectedStartTime!),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedStartTime == null
                                ? TimeOfDay.now()
                                : TimeOfDay.fromDateTime(_selectedStartTime!),
                          );
                          if (time != null) {
                            final now = DateTime.now();
                            setState(() {
                              _selectedStartTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        },
                        onClear: _selectedStartTime == null
                            ? null
                            : () => setState(() => _selectedStartTime = null),
                      ),
                      const SizedBox(height: 8),
                      _ScheduleTile(
                        icon: Icons.event_available,
                        label: 'Дедлайн',
                        value: _selectedDeadline == null
                            ? 'Не выбран'
                            : (() {
                                final dl = _selectedDeadline!;
                                final hasTime = !(dl.hour == 0 &&
                                    dl.minute == 0 &&
                                    dl.second == 0);
                                final locale = Localizations.localeOf(context)
                                    .toLanguageTag();
                                if (hasTime) {
                                  return DateFormat('yMMMd, HH:mm', locale)
                                      .format(dl);
                                } else {
                                  return DateFormat.yMMMd(locale).format(dl);
                                }
                              })(),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDeadline ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                          );
                          if (date != null) {
                            if (!context.mounted) return;
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _selectedDeadline == null
                                  ? TimeOfDay.now()
                                  : TimeOfDay.fromDateTime(_selectedDeadline!),
                            );
                            setState(() {
                              if (time != null) {
                                _selectedDeadline = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              } else {
                                _selectedDeadline = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                );
                              }
                            });
                          }
                        },
                        onClear: _selectedDeadline == null
                            ? null
                            : () => setState(() => _selectedDeadline = null),
                      ),
                      if (_selectedStartTime != null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.taskEstimatedDurationLabel,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            DurationInputField(
                              initialMinutes: _estMin,
                              onChanged: (val) {
                                setState(() {
                                  _estMin = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      ExpandableSection(
                        title: l10n.recurrenceTitle,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.repeat,
                                size: 20,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _recurrenceLabel(l10n, task),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final result = await showDialog<String?>(
                                context: context,
                                builder: (dialogContext) =>
                                    RecurrenceEditorDialog(
                                  initialRRule:
                                      _recurrenceRule ?? task.recurrenceRule,
                                ),
                              );
                              if (result == null) {
                                return;
                              }
                              setState(() {
                                _recurrenceRule = result.trim().isEmpty
                                    ? null
                                    : result.trim();
                              });
                            },
                            icon: const Icon(Icons.repeat),
                            label: Text(l10n.recurrenceTitle),
                          ),
                          if ((task.recurrenceRule?.isNotEmpty ?? false) ||
                              task.parentTaskId != null) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(recurrenceEngineProvider)
                                    .deleteAllExceptInstance(task.toDrift());
                                ref
                                    .read(
                                      taskSchedulingRefreshTriggerProvider,
                                    )
                                    .schedule();
                                if (!context.mounted) {
                                  return;
                                }
                                ref
                                  ..invalidate(taskByIdProvider(widget.taskId))
                                  ..invalidate(
                                    checklistByTaskIdProvider(widget.taskId),
                                  );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Оставлены только текущая копия и её данные',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.content_cut),
                              label: const Text('Оставить только эту копию'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isPinned ?? task.isPinned,
                    onChanged: (v) => setState(() => _isPinned = v),
                    title: Text(l10n.taskPinnedLabel),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _saveTask(task),
                    child: Text(l10n.taskDetailsSaveButton),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
  String _recurrenceLabel(AppLocalizations l10n, Task task) {
    final rule = _recurrenceRule;
    if (rule == null || rule.isEmpty) {
      if (task.parentTaskId != null) {
        return 'Повторяющаяся задача (экземпляр)';
      }
      return task.recurrenceRule?.isNotEmpty ?? false
          ? l10n.recurrenceTitle
          : l10n.recurrenceNone;
    }
    final cleanRule = rule.replaceAll('RRULE:', '').trim();
    if (cleanRule.contains('FREQ=DAILY')) {
      if (cleanRule.contains('BYDAY=MO,TU,WE,TH,FR')) {
        return l10n.recurrenceWeekdays;
      }
      return l10n.recurrenceDaily;
    }
    if (cleanRule.contains('FREQ=WEEKLY')) {
      return l10n.recurrenceWeekly;
    }
    if (cleanRule.contains('FREQ=MONTHLY')) {
      return l10n.recurrenceMonthly;
    }
    if (cleanRule.contains('FREQ=YEARLY')) {
      return l10n.recurrenceYearly;
    }
    return cleanRule;
  }
  DateTime? _composeStartAt(Task task) {
    final selectedDate = _selectedDate;
    final selectedStartTime = _selectedStartTime;
    if (selectedDate != null && selectedStartTime != null) {
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedStartTime.hour,
        selectedStartTime.minute,
      );
    }
    if (selectedDate != null) {
      return DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    }
    if (selectedStartTime != null) {
      return DateTime(
        selectedStartTime.year,
        selectedStartTime.month,
        selectedStartTime.day,
        selectedStartTime.hour,
        selectedStartTime.minute,
      );
    }
    return task.startAt;
  }
  DateTime? _composeEndAt(DateTime? startAt, bool isAllDay, int estMin) {
    if (startAt == null || isAllDay || estMin <= 0) {
      return null;
    }
    return startAt.add(Duration(minutes: estMin));
  }
  Future<void> _syncTaskReminder(Task task) async {
    final service = ref.read(notificationServiceProvider);
    await service.cancelTaskReminder(task.id);
    if (task.startAt == null ||
        task.status == TaskStatus.completed ||
        task.status == TaskStatus.cancelled) {
      return;
    }
    final minutesBefore =
        await ref.read(databaseProvider).settingsDao.getIntValue(
                  notification_settings_keys
                      .SettingsKeys.taskReminderMinutesBefore,
                ) ??
            15;
    await service.scheduleTaskReminder(task, minutesBefore);
  }
}
class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(icon),
            suffixIcon: onClear == null
                ? null
                : IconButton(
                    tooltip: 'Очистить',
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                  ),
          ),
          child: Text(value),
        ),
      ),
    );
  }
}
class _PremiumChecklistItem extends StatefulWidget {
  const _PremiumChecklistItem({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });
  final TaskChecklistItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  @override
  State<_PremiumChecklistItem> createState() => _PremiumChecklistItemState();
}
class _PremiumChecklistItemState extends State<_PremiumChecklistItem>
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
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.08), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onToggle(!widget.item.isDone);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = widget.item.isDone;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDone
              ? theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.05)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _handleTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isDone
                          ? null
                          : Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.5),
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
                                color:
                                    Colors.cyanAccent.withValues(alpha: 0.25),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone
                          ? theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.55)
                          : theme.colorScheme.onSurface,
                      fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: widget.onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.error.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

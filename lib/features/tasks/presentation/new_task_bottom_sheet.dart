import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/notifications/application/notification_providers.dart';
import '../../../core/notifications/domain/settings_keys.dart'
    as notification_settings_keys;
import '../application/task_repository_provider.dart';
import '../../scheduling/application/conflict_resolver.dart';
import '../../scheduling/application/task_scheduling_refresh_trigger.dart';
import 'providers/task_creation_controller.dart';
import '../domain/task.dart' as task_domain;
import '../domain/task_tag.dart';
import '../domain/task_checklist_item.dart';
import '../../voice_input/application/voice_input_controller.dart';
import '../../voice_input/application/voice_input_providers.dart';
import 'widgets/expandable_section.dart';
import 'providers/tasks_provider.dart';
import '../../../core/settings/application/settings_providers.dart';
import '../../recurrence/presentation/recurrence_editor_dialog.dart';
import 'widgets/duration_input_field.dart';
import '../../../core/widgets/glass_container.dart';
import '../../ai_engine/application/llm_service_provider.dart';
class NewTaskBottomSheet extends ConsumerStatefulWidget {
  const NewTaskBottomSheet({
    super.key,
    this.existingTask,
    this.isToday = false,
    this.initialTitle,
    this.forceBypassLlm = false,
    this.onSubmit,
  });
  final task_domain.Task? existingTask;
  final bool isToday;
  final String? initialTitle;
  final bool forceBypassLlm;
  final Future<void> Function(TaskCreationRequest request)? onSubmit;
  static void show(
    BuildContext context, {
    task_domain.Task? task,
    bool isToday = false,
    bool forceBypassLlm = false,
    String? initialTitle,
    Future<void> Function(TaskCreationRequest request)? onSubmit,
  }) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: NewTaskBottomSheet(
            existingTask: task,
            isToday: isToday,
            forceBypassLlm: forceBypassLlm,
            initialTitle: initialTitle,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }
  @override
  ConsumerState<NewTaskBottomSheet> createState() => _NewTaskBottomSheetState();
}
class _NewTaskBottomSheetState extends ConsumerState<NewTaskBottomSheet> {
  static const int _llmTextThreshold = 10;
  final Logger _logger = Logger('NewTaskBottomSheet');
  final ConflictResolver _conflictResolver = ConflictResolver();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _todoInputController;
  DateTime? _selectedStartTime;
  DateTime? _selectedDate;
  DateTime? _selectedDeadline;
  String? _selectedRecurrenceRule;
  final List<TextEditingController> _todoControllers =
      <TextEditingController>[];
  final List<String> _tags = <String>[];
  final List<String> _hiddenTags = <String>[];
  final TextEditingController _tagInputController = TextEditingController();
  bool _voiceUsed = false;
  bool? _pinned;
  int _estMin = 30;
  bool _customEstMinSelected = false;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingTask?.title ?? widget.initialTitle ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingTask?.notes ?? '',
    );
    _pinned = widget.existingTask?.isPinned;
    _estMin = widget.existingTask?.estMin ?? 30;
    _customEstMinSelected = widget.existingTask != null;
    _todoInputController = TextEditingController();
    _selectedStartTime = widget.existingTask?.startAt;
    _selectedDate = widget.existingTask?.startAt;
    _selectedDeadline = widget.existingTask?.deadlineAt;
    _selectedRecurrenceRule = widget.existingTask?.recurrenceRule;
    if (widget.existingTask != null) {
      Future(() async {
        try {
          final items = await ref
              .read(checklistRepositoryProvider)
              .getByTaskId(widget.existingTask!.id);
          items.toList(growable: false)
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex))
            ..forEach((item) => _addChecklistItem(item.title));
          if (mounted) setState(() {});
        } on Object catch (e) {
          _logger.warning('Failed to load checklist items', e);
        }
      });
      Future(() async {
        try {
          final tags = await ref
              .read(taskTagRepositoryProvider)
              .getByTaskId(widget.existingTask!.id);
          final allTags = tags.map((t) => t.tagName).toList();
          if (allTags.length > 3) {
            _tags.addAll(allTags.take(3));
            _hiddenTags.addAll(allTags.skip(3));
          } else {
            _tags.addAll(allTags);
          }
          if (mounted) setState(() {});
        } on Object catch (e) {
          _logger.warning('Failed to load tags', e);
        }
      });
    }
    if (widget.existingTask == null) {
      unawaited(ref.read(llmServiceProvider).warmup());
    }
  }
  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _todoInputController.dispose();
    _tagInputController.dispose();
    for (final controller in _todoControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  void _addChecklistItem([String? initialValue]) {
    final controller = TextEditingController(text: initialValue ?? '');
    setState(() {
      _todoControllers.add(controller);
    });
  }
  void _removeChecklistItem(int index) {
    setState(() {
      _todoControllers.removeAt(index).dispose();
    });
  }
  List<String> _collectChecklistItems() {
    final items = _todoControllers
        .map((controller) => controller.text.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final seen = <String>{};
    final unique = <String>[];
    for (final item in items) {
      final normalized = item.toLowerCase();
      if (!seen.contains(normalized)) {
        seen.add(normalized);
        unique.add(item);
      }
    }
    return unique;
  }
  void _addTag(String tag) {
    final trimmed = tag.trim().toLowerCase();
    if (trimmed.isEmpty || _tags.length >= 3) return;
    if (!_tags.map((t) => t.toLowerCase()).contains(trimmed)) {
      setState(() {
        _tags.add(tag.trim());
      });
    }
  }
  void _removeTag(String tag) {
    setState(() {
      _tags.removeWhere((t) => t.toLowerCase() == tag.toLowerCase());
    });
  }
  void _applyVoiceText(String text) {
    if (text.trim().isEmpty) {
      return;
    }
    _titleController
      ..text = text.trim()
      ..selection = TextSelection.collapsed(
        offset: text.trim().length,
      );
  }
  Future<void> _submit() async {
    final inputText = _titleController.text.trim();
    if (inputText.isEmpty) {
      return;
    }
    final startAt = _manualStartAt();
    final isAllDay = _selectedDate != null && _selectedStartTime == null;
    if (startAt != null && !isAllDay) {
      final conflicts = _conflictResolver.getConflictingExactStartTimes(
        start: startAt,
        existingTasks: await ref.read(tasksDaoProvider).getAllTasks(),
        ignoreTaskId: widget.existingTask?.id,
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
    final isLlmFlow = !widget.forceBypassLlm &&
        (_voiceUsed || inputText.length > _llmTextThreshold);
    final manualIsAllDay = _selectedDate != null
        ? (_selectedStartTime == null)
        : null;
    final request = TaskCreationRequest(
      text: inputText,
      notes: _notesController.text.trim(),
      checklistItems: _collectChecklistItems(),
      isToday: widget.isToday,
      useLlm: isLlmFlow,
      isPinned: _pinned,
      startAt: startAt,
      deadlineAt: _selectedDeadline,
      isAllDay: manualIsAllDay,
      recurrenceRule: _selectedRecurrenceRule,
      estMin: _customEstMinSelected ? _estMin : null,
      tags: [..._tags, ..._hiddenTags],
    );
    if (widget.existingTask != null) {
      final updatedTask = widget.existingTask!.copyWith(
        title: inputText,
        notes: _notesController.text.trim(),
        isPinned: _pinned ?? widget.existingTask!.isPinned,
        startAt: startAt,
        endAt: _composeEndAt(startAt, isAllDay, _estMin),
        deadlineAt: _selectedDeadline ?? widget.existingTask!.deadlineAt,
        isAllDay: isAllDay,
        recurrenceRule: _selectedRecurrenceRule,
        estMin: _estMin,
      );
      await ref.read(taskRepositoryProvider).update(updatedTask);
      await _syncTaskReminder(updatedTask);
      ref.read(taskSchedulingRefreshTriggerProvider).schedule();
      try {
        final checklistRepo = ref.read(checklistRepositoryProvider);
        final existingItems =
            await checklistRepo.getByTaskId(widget.existingTask!.id);
        existingItems.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        final newTitles = _collectChecklistItems();
        final createdIds = <String>[];
        final common = min(existingItems.length, newTitles.length);
        for (var i = 0; i < common; i++) {
          final existing = existingItems[i];
          final newTitle = newTitles[i];
          if (existing.title.toLowerCase() != newTitle.toLowerCase()) {
            await checklistRepo.update(existing.copyWith(title: newTitle));
          }
        }
        if (newTitles.length > existingItems.length) {
          for (var i = existingItems.length; i < newTitles.length; i++) {
            final newItem = TaskChecklistItem(
              id: const Uuid().v4(),
              taskId: widget.existingTask!.id,
              title: newTitles[i],
              orderIndex: DateTime.now().millisecondsSinceEpoch + i,
            );
            await checklistRepo.save(newItem);
            createdIds.add(newItem.id);
          }
        }
        if (newTitles.length < existingItems.length) {
          for (var i = newTitles.length; i < existingItems.length; i++) {
            await checklistRepo.delete(existingItems[i].id);
          }
        }
        final newOrderIds = <String>[];
        for (var i = 0; i < newTitles.length; i++) {
          if (i < existingItems.length) {
            newOrderIds.add(existingItems[i].id);
          } else {
            newOrderIds.add(createdIds[i - existingItems.length]);
          }
        }
        if (newOrderIds.isNotEmpty) {
          await checklistRepo.reorder(widget.existingTask!.id, newOrderIds);
        }
      } on Object catch (e) {
        _logger.warning('Failed to sync checklist on task update', e);
      }
      try {
        final tagRepo = ref.read(taskTagRepositoryProvider);
        final existingTags = await tagRepo.getByTaskId(widget.existingTask!.id);
        for (final t in existingTags) {
          await tagRepo.delete(t.id);
        }
        final combinedTags = [..._tags, ..._hiddenTags];
        for (var i = 0; i < combinedTags.length; i++) {
          await ref.read(taskTagRepositoryProvider).save(
                TaskTag(
                  id: const Uuid().v4(),
                  taskId: widget.existingTask!.id,
                  tagName: combinedTags[i],
                  isPrimary: i == 0,
                ),
              );
        }
      } on Object catch (e) {
        _logger.warning('Failed to sync tags on task update', e);
      }
    } else {
      if (widget.onSubmit != null) {
        unawaited(widget.onSubmit!(request));
      } else {
        unawaited(
          ref.read(taskCreationControllerProvider.notifier).create(request),
        );
      }
    }
    if (mounted) {
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }
  DateTime? _manualStartAt() {
    final date = _selectedDate;
    final time = _selectedStartTime;
    if (date != null && time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }
    if (date != null) {
      return DateTime(date.year, date.month, date.day);
    }
    if (time != null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    }
    return widget.existingTask?.startAt;
  }
  DateTime? _composeEndAt(DateTime? startAt, bool isAllDay, int estMin) {
    if (startAt == null || isAllDay || estMin <= 0) {
      return null;
    }
    return startAt.add(Duration(minutes: estMin));
  }
  Future<void> _startVoiceRecording() async {
    _logger.info('Requesting microphone permission');
    if (!Platform.isMacOS) {
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        if (!mounted) {
          return;
        }
        _logger.warning('Microphone permission denied');
        await _showPermissionDialog();
        return;
      }
    }
    _logger.info('Starting voice recording');
    try {
      await ref.read(voiceInputControllerProvider.notifier).startRecording();
      _voiceUsed = true;
      _logger.info('Voice recording started');
    } on Object catch (e) {
      _logger.warning('Failed to start voice recording', e);
    }
  }
  Future<void> _stopVoiceRecording() async {
    _logger.info('Stopping voice recording and requesting transcription');
    try {
      await ref.read(voiceInputControllerProvider.notifier).stopAndTranscribe();
      _logger.info('Stop/Transcribe completed');
    } on Object catch (e) {
      _logger.warning('Error during stopAndTranscribe', e);
    }
  }
  Future<void> _syncTaskReminder(task_domain.Task task) async {
    final service = ref.read(notificationServiceProvider);
    await service.cancelTaskReminder(task.id);
    if (task.startAt == null ||
        task.status == task_domain.TaskStatus.completed ||
        task.status == task_domain.TaskStatus.cancelled) {
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
  Future<void> _showPermissionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.voicePermissionTitle),
          content: Text(l10n.voicePermissionBody),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await openAppSettings();
                } on MissingPluginException catch (_) {
                }
              },
              child: Text(l10n.openSettingsButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.closeButton),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    ref.listen<VoiceInputState>(voiceInputControllerProvider, (_, next) {
      switch (next) {
        case VoiceInputDone(:final text):
          _applyVoiceText(text);
        case VoiceInputError(:final message):
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        case VoiceInputIdle():
        case VoiceInputRecording():
        case VoiceInputTranscribing():
      }
    });
    final voiceState = ref.watch(voiceInputControllerProvider);
    return GlassContainer(
      blur: 30,
      bgOpacity: 0.2,
      borderOpacity: 0.3,
      borderRadius: 24,
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.existingTask == null
                      ? l10n.newTaskSheetTitle
                      : l10n.newTaskEditTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: l10n.newTaskWhatNeedsToBeDone,
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => unawaited(_submit()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _VoiceInputButton(
                      voiceState: voiceState,
                      onPressStart: () => unawaited(_startVoiceRecording()),
                      onPressEnd: () => unawaited(_stopVoiceRecording()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.taskChecklistSectionTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _todoInputController,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: l10n.taskChecklistAddLabel,
                    prefixIcon: const Icon(Icons.add_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.playlist_add_rounded),
                      onPressed: () {
                        final trimmed = _todoInputController.text.trim();
                        if (trimmed.isEmpty) {
                          return;
                        }
                        _todoInputController.clear();
                        _addChecklistItem(trimmed);
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    final trimmed = value.trim();
                    if (trimmed.isEmpty) {
                      return;
                    }
                    _todoInputController.clear();
                    _addChecklistItem(trimmed);
                  },
                ),
                if (_todoControllers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...List.generate(_todoControllers.length, (index) {
                    final controller = _todoControllers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_box_outline_blank_rounded,
                              size: 20,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                style: theme.textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  hintText: l10n.taskChecklistItemLabel,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () => _removeChecklistItem(index),
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: theme.colorScheme.error
                                    .withValues(alpha: 0.8),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 16),
                ExpandableSection(
                  title: l10n.tagsTitle,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...List.generate(_tags.length, (index) {
                          final tag = _tags[index];
                          return InputChip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: index == 0
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            labelStyle: TextStyle(
                              color: index == 0
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: index == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }),
                        if (_tags.length < 3)
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _tagInputController,
                              decoration: InputDecoration(
                                hintText: 'Новый тег',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  _addTag(val);
                                  _tagInputController.clear();
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                    if (_tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Первый тег является основным.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ExpandableSection(
                  title: l10n.taskNotesSectionTitle,
                  children: [
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: l10n.newTaskNotes,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ExpandableSection(
                  title: '📅 Время, дата и дедлайн',
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                final now = DateTime.now();
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
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Время начала',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.schedule),
                            ),
                            child: Text(
                              _selectedStartTime != null
                                  ? DateFormat.Hm(
                                      Localizations.localeOf(context)
                                          .toLanguageTag(),
                                    ).format(_selectedStartTime!)
                                  : 'Выберите время',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Дата',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedDate != null
                                  ? DateFormat.yMMMd(
                                      Localizations.localeOf(context)
                                          .toLanguageTag(),
                                    ).format(_selectedDate!)
                                  : 'Выберите дату',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => _selectedDeadline = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Дедлайн',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.event_available),
                            ),
                            child: Text(
                              _selectedDeadline != null
                                  ? DateFormat.yMMMd(
                                      Localizations.localeOf(context)
                                          .toLanguageTag(),
                                    ).format(_selectedDeadline!)
                                  : 'Выберите дедлайн',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        if (_selectedStartTime != null) ...[
                          const SizedBox(height: 12),
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
                                    _customEstMinSelected = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ExpandableSection(
                  title: l10n.recurrenceTitle,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await showDialog<String?>(
                          context: context,
                          builder: (dialogContext) => RecurrenceEditorDialog(
                            initialRRule: _selectedRecurrenceRule,
                          ),
                        );
                        if (result == null) {
                          return;
                        }
                        setState(() {
                          _selectedRecurrenceRule =
                              result.trim().isEmpty ? null : result.trim();
                        });
                      },
                      icon: const Icon(Icons.repeat),
                      label: Text(_recurrenceLabel(l10n)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<bool>(
                  future: ref.read(defaultTaskPinnedProvider.future),
                  builder: (context, snapshot) {
                    final defaultPinned = snapshot.data ?? false;
                    final value = _pinned ?? defaultPinned;
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: value,
                      onChanged: (v) => setState(() => _pinned = v),
                      title: Text(l10n.taskPinnedLabel),
                    );
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submit,
                  child: Text(
                    widget.existingTask == null
                        ? l10n.newTaskCreateButton
                        : l10n.taskDetailsSaveButton,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  String _recurrenceLabel(AppLocalizations l10n) {
    final rule = _selectedRecurrenceRule;
    if (rule == null || rule.isEmpty) {
      return l10n.recurrenceNone;
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
}
class _VoiceInputButton extends StatelessWidget {
  const _VoiceInputButton({
    required this.voiceState,
    required this.onPressStart,
    required this.onPressEnd,
  });
  final VoiceInputState voiceState;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onPressStart(),
      onTapUp: (_) => onPressEnd(),
      onTapCancel: onPressEnd,
      child: Semantics(
        label: l10n.voiceMicTooltip,
        button: true,
        child: SizedBox(
          width: 56,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: switch (voiceState) {
                VoiceInputTranscribing() => const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                VoiceInputRecording(:final amplitude) =>
                  _PulseDots(amplitude: amplitude),
                _ => Icon(
                    Icons.mic,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}
class _PulseDots extends StatelessWidget {
  const _PulseDots({required this.amplitude});
  final double amplitude;
  @override
  Widget build(BuildContext context) {
    final scale = 0.7 + (amplitude.clamp(0, 1) * 0.6);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final factor = (index - 2).abs() / 2;
        final size = 5 + (scale * 6 * (1 - factor));
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

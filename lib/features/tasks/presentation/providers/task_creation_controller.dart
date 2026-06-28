import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/settings/domain/settings_keys.dart';
import '../../../../core/settings/application/settings_providers.dart';
import '../../../../core/llm/domain/ai_profile.dart';
import '../../../../core/notifications/application/notification_providers.dart';
import '../../../../core/notifications/domain/settings_keys.dart'
    as notification_settings_keys;
import '../../../ai_engine/application/llm_service_provider.dart';
import '../../../ai_engine/domain/llm_service.dart';
import '../../../recurrence/application/recurrence_engine_provider.dart';
import '../../application/task_repository_provider.dart';
import '../../data/drift_task_repository.dart';
import '../../domain/task.dart' as task_domain;
import '../../domain/checklist_repository.dart';
import '../../domain/task_tag.dart';
import '../../domain/task_tag_repository.dart';
import '../../domain/task_checklist_item.dart';
import '../../../scheduling/application/conflict_resolver.dart';
import '../../../scheduling/application/task_scheduling_refresh_trigger.dart';
class TaskCreationRequest {
  const TaskCreationRequest({
    required this.text,
    required this.notes,
    required this.checklistItems,
    required this.isToday,
    required this.useLlm,
    this.isPinned,
    this.startAt,
    this.deadlineAt,
    this.isAllDay,
    this.recurrenceRule,
    this.estMin,
    this.tags = const <String>[],
  });
  final String text;
  final String notes;
  final List<String> checklistItems;
  final bool isToday;
  final bool useLlm;
  final bool? isPinned;
  final DateTime? startAt;
  final DateTime? deadlineAt;
  final bool? isAllDay;
  final String? recurrenceRule;
  final int? estMin;
  final List<String> tags;
}
final taskCreationControllerProvider =
    StateNotifierProvider<TaskCreationController, AsyncValue<LLMTelemetry?>>((ref) {
  return TaskCreationController(ref);
});
class TaskCreationController extends StateNotifier<AsyncValue<LLMTelemetry?>> {
  TaskCreationController(this._ref) : super(const AsyncData(null));
  final Ref _ref;
  final Logger _logger = Logger('TaskCreationController');
  final ConflictResolver _conflictResolver = ConflictResolver();
  Future<void> create(TaskCreationRequest request) async {
    state = const AsyncLoading<LLMTelemetry?>();
    try {
      final telemetry = await _createInternal(request);
      state = AsyncData(telemetry);
    } on Object catch (error, stackTrace) {
      _logger.severe('Task creation failed', error, stackTrace);
      state = AsyncError<LLMTelemetry?>(error, stackTrace);
    }
  }
  Future<LLMTelemetry?> _createInternal(TaskCreationRequest request) async {
    final taskRepository = _ref.read(taskRepositoryProvider);
    final checklistRepository = _ref.read(checklistRepositoryProvider);
    final tagRepository = _ref.read(taskTagRepositoryProvider);
    final llmService = _ref.read(llmServiceProvider);
    final now = DateTime.now();
    LLMTelemetry? telemetry;
    List<TaskDTO> dtos;
    if (request.useLlm) {
      final experimentalEnabled = _ref.read(experimentalFeaturesNotifierProvider);
      final watch = experimentalEnabled ? (Stopwatch()..start()) : null;
      final parseResult = await _parseWithGemma(llmService, request.text);
      dtos = parseResult.tasks;
      if (experimentalEnabled && watch != null && parseResult.quality != ParseQuality.fallback) {
        watch.stop();
        final rawResponse = parseResult.rawResponse ?? '';
        final approxTokens = rawResponse.length / 4;
        final seconds = watch.elapsedMilliseconds / 1000.0;
        final tps = seconds > 0 ? (approxTokens / seconds) : 0.0;
        telemetry = LLMTelemetry(
          backend: llmService.activeBackend,
          elapsedMs: watch.elapsedMilliseconds,
          tokensPerSecond: tps,
        );
      }
    } else {
      dtos = [_fallbackDto(request.text)];
    }
    final manualNotes = request.notes.trim();
    final manualChecklist = _normalizeChecklist(request.checklistItems);
    final manualRecurrenceRule =
        _normalizeRecurrenceRule(request.recurrenceRule);
    final manualStartAt = request.startAt;
    final manualDeadlineAt = request.deadlineAt;
    final manualIsAllDay = request.isAllDay;
    final manualTags = request.tags;
    for (final dto in dtos) {
      final taskId = const Uuid().v4();
      final mergedNotes = _mergeNotes(dto.notes, manualNotes);
      final mergedChecklist =
          _mergeChecklist(dto.checklistItems, manualChecklist);
      final mergedTags = _mergeTags(dto.tags, manualTags);
      final finalDto = dto.copyWith(
        notes: mergedNotes,
        checklistItems: mergedChecklist,
        tags: mergedTags,
        startAt: manualStartAt ?? dto.startAt,
        deadlineAt: manualDeadlineAt ?? dto.deadlineAt,
        isAllDay: manualIsAllDay ?? dto.isAllDay,
        recurrenceRule: manualRecurrenceRule ?? dto.recurrenceRule,
        estMin: request.estMin ?? dto.estMin,
      );
      final task = await _toDomainTask(
        dto: finalDto,
        taskId: taskId,
        now: now,
        requestedPinned: request.isPinned,
      );
      await _ensureNoExactTimeConflict(task);
      await taskRepository.save(task);
      await _saveChecklistItems(
        checklistRepository,
        taskId: taskId,
        itemTitles: mergedChecklist,
      );
      await _saveTags(
        tagRepository,
        taskId: taskId,
        tags: mergedTags,
      );
      await _syncTaskReminder(task);
      if (task.recurrenceRule != null) {
        final recurrenceEngine = _ref.read(recurrenceEngineProvider);
        await recurrenceEngine.materialize(
          templateTask: task.toDrift(),
          startDate: task.startAt ?? now,
          days: 365,
        );
      }
    }
    _ref.read(taskSchedulingRefreshTriggerProvider).schedule();
    return telemetry;
  }
  Future<void> _ensureNoExactTimeConflict(task_domain.Task task) async {
    final startAt = task.startAt;
    if (startAt == null || task.isAllDay) {
      return;
    }
    final conflicts = _conflictResolver.getConflictingExactStartTimes(
      start: startAt,
      existingTasks: await _ref.read(databaseProvider).tasksDao.getAllTasks(),
      ignoreTaskId: task.id,
    );
    if (conflicts.isNotEmpty) {
      throw const TaskCreationConflictException();
    }
  }
  Future<LLMParseResult> _parseWithGemma(
    LLMService llmService,
    String text,
  ) async {
    try {
      final profile = await _readAiProfile();
      final cleanedText = _cleanUserText(text);
      return await llmService.parseTask(cleanedText, profile);
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Gemma parse failed, falling back to plain task',
        error,
        stackTrace,
      );
      return LLMParseResult(
        tasks: [_fallbackDto(text)],
        quality: ParseQuality.fallback,
      );
    }
  }
  String _cleanUserText(String text) {
    var cleaned = text.trim();
    cleaned = cleaned.replaceFirst(RegExp(r'^[зЗ]апрос:\s*'), '').trim();
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    } else if (cleaned.startsWith('«') && cleaned.endsWith('»')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    }
    return cleaned;
  }
  TaskDTO _fallbackDto(String text) {
    return TaskDTO(
      title: text.trim(),
      notes: '',
      startAt: null,
      endAt: null,
      deadlineAt: null,
      isAllDay: false,
      estMin: 30,
      priority: task_domain.TaskPriority.medium,
      tags: const <String>[],
      checklistItems: const <String>[],
      recurrenceRule: null,
      confidence: 1.0,
    );
  }
  Future<AIProfile> _readAiProfile() async {
    final row = await _ref.read(databaseProvider).aiProfileDao.getProfile();
    if (row == null) {
      return const AIProfile();
    }
    return AIProfile(
      correctionFactor: row.correctionFactor,
      avgMoodScore: row.avgMoodScore,
      peakHoursStart: row.peakHoursStart,
      peakHoursEnd: row.peakHoursEnd,
      totalCheckins: row.totalCheckins,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }
  Future<task_domain.Task> _toDomainTask({
    required TaskDTO dto,
    required String taskId,
    required DateTime now,
    bool? requestedPinned,
  }) async {
    final startAt = dto.startAt;
    final settingsDao = _ref.read(databaseProvider).settingsDao;
    final defaultPinned =
        await settingsDao.getBoolValue(SettingsKeys.defaultTaskPinned) ?? false;
    final isPinned = requestedPinned ?? defaultPinned;
    return task_domain.Task(
      id: taskId,
      title: dto.title,
      notes: dto.notes ?? '',
      deadlineAt: dto.deadlineAt,
      startAt: startAt,
      endAt: dto.endAt ?? _composeEndAt(startAt, dto.isAllDay, dto.estMin),
      isAllDay: dto.isAllDay,
      isPinned: isPinned,
      estMin: dto.estMin,
      priority: dto.priority,
      recurrenceRule: dto.recurrenceRule,
      createdAt: now,
      updatedAt: now,
      aiConfidence: dto.confidence,
    );
  }
  DateTime? _composeEndAt(DateTime? startAt, bool isAllDay, int estMin) {
    if (startAt == null || isAllDay || estMin <= 0) {
      return null;
    }
    return startAt.add(Duration(minutes: estMin));
  }
  String? _normalizeRecurrenceRule(String? recurrenceRule) {
    final trimmed = recurrenceRule?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    if (trimmed.startsWith('RRULE:')) {
      return trimmed.substring('RRULE:'.length);
    }
    return trimmed;
  }
  Future<void> _saveChecklistItems(
    ChecklistRepository checklistRepository, {
    required String taskId,
    required List<String> itemTitles,
  }) async {
    final seen = <String>{};
    for (var index = 0; index < itemTitles.length; index++) {
      final title = itemTitles[index].trim();
      if (title.isEmpty) {
        continue;
      }
      final normalized = title.toLowerCase();
      if (seen.contains(normalized)) {
        continue;
      }
      seen.add(normalized);
      await checklistRepository.save(
        TaskChecklistItem(
          id: const Uuid().v4(),
          taskId: taskId,
          title: title,
          orderIndex: index,
        ),
      );
    }
  }
  Future<void> _syncTaskReminder(task_domain.Task task) async {
    final service = _ref.read(notificationServiceProvider);
    await service.cancelTaskReminder(task.id);
    if (task.startAt == null ||
        task.status == task_domain.TaskStatus.completed ||
        task.status == task_domain.TaskStatus.cancelled) {
      return;
    }
    final minutesBefore =
        await _ref.read(databaseProvider).settingsDao.getIntValue(
                  notification_settings_keys
                      .SettingsKeys.taskReminderMinutesBefore,
                ) ??
            15;
    await service.scheduleTaskReminder(task, minutesBefore);
  }
  List<String> _normalizeChecklist(List<String> items) {
    return items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  List<String> _mergeChecklist(
    List<String> aiItems,
    List<String> manualItems,
  ) {
    final merged = <String>[];
    final seenNormalized = <String>{};
    for (final item in [...manualItems, ...aiItems]) {
      if (item.isEmpty) {
        continue;
      }
      final normalized = item.trim().toLowerCase();
      if (seenNormalized.contains(normalized)) {
        continue;
      }
      seenNormalized.add(normalized);
      merged.add(item.trim());
    }
    return merged;
  }
  String _mergeNotes(String? aiNotes, String manualNotes) {
    final pieces = <String>[];
    final parsed = aiNotes?.trim();
    if (parsed != null && parsed.isNotEmpty) {
      pieces.add(parsed);
    }
    if (manualNotes.isNotEmpty) {
      pieces.add(manualNotes);
    }
    return pieces.join('\n');
  }
  List<String> _mergeTags(List<String> aiTags, List<String> manualTags) {
    final merged = <String>[];
    final seen = <String>{};
    for (final item in [...manualTags, ...aiTags]) {
      if (item.isEmpty) {
        continue;
      }
      final normalized = item.trim().toLowerCase();
      if (seen.contains(normalized)) {
        continue;
      }
      seen.add(normalized);
      merged.add(item.trim());
    }
    return merged.take(5).toList(growable: false);
  }
  Future<void> _saveTags(
    TaskTagRepository repository, {
    required String taskId,
    required List<String> tags,
  }) async {
    for (var i = 0; i < tags.length; i++) {
      await repository.save(
        TaskTag(
          id: const Uuid().v4(),
          taskId: taskId,
          tagName: tags[i],
          isPrimary: i == 0,
        ),
      );
    }
  }
}
class TaskCreationConflictException implements Exception {
  const TaskCreationConflictException();
}

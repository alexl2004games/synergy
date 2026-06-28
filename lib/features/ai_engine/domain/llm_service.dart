import '../../../core/llm/domain/ai_profile.dart';
import '../../tasks/domain/task.dart';
enum AIActionType { createTasks, executeCommands }
class LLMTelemetry {
  const LLMTelemetry({
    required this.backend,
    required this.elapsedMs,
    required this.tokensPerSecond,
  });
  final String backend;
  final int elapsedMs;
  final double tokensPerSecond;
}
abstract class LLMService {
  Future<void> initialize();
  Future<void> warmup();
  String get activeBackend;
  Future<LLMParseResult> parseTask(String userText, AIProfile profile);
  Future<void> dispose();
}
enum ParseQuality {
  high,
  medium,
  low,
  fallback,
}
class AICommandDTO {
  const AICommandDTO({
    required this.type,
    required this.changes,
    this.targetTaskTitle,
  });
  final String
      type;
  final String? targetTaskTitle;
  final Map<String, dynamic> changes;
}
class LLMParseResult {
  const LLMParseResult({
    required this.tasks,
    required this.quality,
    this.commands = const [],
    this.action = AIActionType.createTasks,
    this.rawResponse,
    this.error,
  });
  final List<TaskDTO> tasks;
  final List<AICommandDTO> commands;
  final AIActionType action;
  final ParseQuality quality;
  final String? rawResponse;
  final String? error;
  TaskDTO get task {
    if (tasks.isNotEmpty) {
      return tasks.first;
    }
    return const TaskDTO(
      title: '',
      notes: '',
      startAt: null,
      endAt: null,
      deadlineAt: null,
      isAllDay: false,
      estMin: 30,
      priority: TaskPriority.medium,
      tags: [],
      checklistItems: [],
      recurrenceRule: null,
      confidence: 1.0,
    );
  }
}
class TaskDTO {
  const TaskDTO({
    required this.title,
    required this.notes,
    required this.startAt,
    required this.endAt,
    required this.deadlineAt,
    required this.isAllDay,
    required this.estMin,
    required this.priority,
    required this.tags,
    required this.checklistItems,
    required this.recurrenceRule,
    required this.confidence,
  });
  final String title;
  final String? notes;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? deadlineAt;
  final bool isAllDay;
  final int estMin;
  final TaskPriority priority;
  final List<String> tags;
  final List<String> checklistItems;
  final String? recurrenceRule;
  final double confidence;
  TaskDTO copyWith({
    String? title,
    String? notes,
    DateTime? startAt,
    bool clearStartAt = false,
    DateTime? endAt,
    bool clearEndAt = false,
    DateTime? deadlineAt,
    bool clearDeadlineAt = false,
    bool? isAllDay,
    int? estMin,
    TaskPriority? priority,
    List<String>? tags,
    List<String>? checklistItems,
    String? recurrenceRule,
    double? confidence,
  }) {
    return TaskDTO(
      title: title ?? this.title,
      notes: notes ?? this.notes,
      startAt: clearStartAt ? null : (startAt ?? this.startAt),
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      deadlineAt: clearDeadlineAt ? null : (deadlineAt ?? this.deadlineAt),
      isAllDay: isAllDay ?? this.isAllDay,
      estMin: estMin ?? this.estMin,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      checklistItems: checklistItems ?? this.checklistItems,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      confidence: confidence ?? this.confidence,
    );
  }
}

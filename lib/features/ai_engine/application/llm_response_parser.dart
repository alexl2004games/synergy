import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/llm/domain/ai_profile.dart';
import '../../tasks/domain/task.dart';
import '../domain/llm_service.dart';
class LLMResponseParser {
  const LLMResponseParser();
  static final Logger _logger = Logger('LLMResponseParser');
  Future<LLMParseResult> parse({
    required String userText,
    required String rawResponse,
    required AIProfile profile,
  }) async {
    _logger
      ..info('Parsing LLM response (len=${rawResponse.length})')
      ..fine('Raw response: $rawResponse');
    try {
      final payload = _extractJson(rawResponse);
      if (payload == null) {
        _logger.warning('JSON payload not found in response');
        throw const FormatException('json_payload_not_found');
      }
      _logger.fine('Extracted JSON: $payload');
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('json_root_is_not_object');
      }
      return _parseFromJsonMap(decoded, userText, profile, rawResponse);
    } on Object catch (error) {
      _logger.warning('Parse failed: $error');
      await _appendErrorLog(
        userText: userText,
        rawResponse: rawResponse,
        error: error.toString(),
      );
      rethrow;
    }
  }
  Future<LLMParseResult> parseFromMap({
    required String userText,
    required Map<String, dynamic> json,
    required AIProfile profile,
    required String rawResponse,
  }) async {
    _logger.info(
      'Parsing LLM response from Map (json keys=${json.keys.toList()})',
    );
    try {
      return _parseFromJsonMap(json, userText, profile, rawResponse);
    } on Object catch (error) {
      _logger.warning('Parse from map failed: $error');
      await _appendErrorLog(
        userText: userText,
        rawResponse: rawResponse,
        error: error.toString(),
      );
      rethrow;
    }
  }
  LLMParseResult _parseFromJsonMap(
    Map<String, dynamic> rawJson,
    String userText,
    AIProfile profile,
    String rawResponse,
  ) {
    var json = rawJson;
    if (json.containsKey('tool_calls') && json['tool_calls'] is List) {
      final toolCalls = json['tool_calls'] as List;
      if (toolCalls.isNotEmpty && toolCalls.first is Map) {
        final firstCall = toolCalls.first as Map;
        if (firstCall.containsKey('function') && firstCall['function'] is Map) {
          final function = firstCall['function'] as Map;
          if (function.containsKey('arguments') && function['arguments'] is Map) {
            json = Map<String, dynamic>.from(function['arguments'] as Map);
            _logger.info('Unwrapped tool_calls arguments from raw JSON: ${json.keys}');
          }
        }
      }
    }
    final actionStr = _safeString(json['action']) ?? 'create_tasks';
    final action = actionStr == 'execute_commands'
        ? AIActionType.executeCommands
        : AIActionType.createTasks;
    final tasks = <TaskDTO>[];
    final commands = <AICommandDTO>[];
    if (json.containsKey('commands') && json['commands'] is List) {
      final cmdsList = json['commands'] as List;
      for (final cmdObj in cmdsList) {
        if (cmdObj is Map<String, dynamic>) {
          final type = _safeString(cmdObj['type']) ?? '';
          final targetTitle = _safeString(cmdObj['target_task_title']);
          final changesMap = cmdObj['changes'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(cmdObj['changes'] as Map)
              : <String, dynamic>{};
          commands.add(
            AICommandDTO(
              type: type,
              targetTaskTitle: targetTitle,
              changes: changesMap,
            ),
          );
        }
      }
    }
    if (json.containsKey('tasks') && json['tasks'] is List) {
      final tasksList = json['tasks'] as List;
      for (final taskObj in tasksList) {
        if (taskObj is Map<String, dynamic>) {
          tasks.add(_validateAndBuildTask(taskObj, userText, profile));
        }
      }
    } else if (action == AIActionType.createTasks) {
      tasks.add(_validateAndBuildTask(json, userText, profile));
    }
    return LLMParseResult(
      tasks: tasks,
      quality: ParseQuality.high,
      commands: commands,
      action: action,
      rawResponse: rawResponse,
    );
  }
  String? _extractJson(String rawResponse) {
    var trimmed = rawResponse.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.startsWith('```json')) {
      trimmed = trimmed.substring(7);
    } else if (trimmed.startsWith('```')) {
      trimmed = trimmed.substring(3);
    }
    if (trimmed.endsWith('```')) {
      trimmed = trimmed.substring(0, trimmed.length - 3);
    }
    trimmed = trimmed.trim();
    final firstBrace = trimmed.indexOf('{');
    if (firstBrace == -1) {
      return null;
    }
    final jsonCandidate = trimmed.substring(firstBrace);
    try {
      jsonDecode(jsonCandidate);
      return jsonCandidate;
    } on Object catch (_) {
      try {
        final repaired = _repairJson(jsonCandidate);
        jsonDecode(repaired);
        _logger.info('Successfully repaired truncated JSON response');
        return repaired;
      } on Object catch (e) {
        _logger.warning('Failed to repair JSON candidate: $e');
        return null;
      }
    }
  }
  String _repairJson(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;
    final stack = <String>[];
    var inString = false;
    var escaped = false;
    for (var i = 0; i < s.length; i++) {
      final char = s[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (char == r'\') {
        escaped = true;
        continue;
      }
      if (char == '"') {
        inString = !inString;
        continue;
      }
      if (!inString) {
        if (char == '{' || char == '[') {
          stack.add(char);
        } else if (char == '}' || char == ']') {
          if (stack.isNotEmpty) {
            final expected = stack.last == '{' ? '}' : ']';
            if (char == expected) {
              stack.removeLast();
            }
          }
        }
      }
    }
    var repaired = s;
    if (inString) {
      if (repaired.endsWith(r'\')) {
        repaired = repaired.substring(0, repaired.length - 1);
      }
      repaired += '"';
    }
    // Очищаем хвост от лишних запятых, двоеточий, пробелов перед закрытием скобок
    repaired = repaired.trim();
    while (repaired.endsWith(',') ||
        repaired.endsWith(':') ||
        repaired.endsWith(' ') ||
        repaired.endsWith('\n') ||
        repaired.endsWith('\r')) {
      repaired = repaired.substring(0, repaired.length - 1).trim();
    }
    // Закрываем скобки в обратном порядке
    while (stack.isNotEmpty) {
      final last = stack.removeLast();
      if (last == '{') {
        repaired += '}';
      } else if (last == '[') {
        repaired += ']';
      }
    }
    return repaired;
  }
  TaskDTO _validateAndBuildTask(
    Map<String, dynamic> json,
    String userText,
    AIProfile profile,
  ) {
    _logger
      ..info('═════ VALIDATION START ═════')
      ..info('userText="$userText"')
      ..info('Raw JSON: $json');
    final title = _safeTitle(_jsonValue(json, ['title']), userText);
    final notes = _safeString(_jsonValue(json, ['notes']));
    final rawStartAt = _safeDate(_jsonValue(json, ['start_at', 'startAt']));
    final rawEndAt = _safeDate(_jsonValue(json, ['end_at', 'endAt']));
    final rawDeadlineAt =
        _safeDate(_jsonValue(json, ['deadline_at', 'deadlineAt']));
    final finalChecklist = _safeStrings(
      _jsonValue(json, ['checklist_items', 'checklistItems']),
      limit: 10,
    );
    final recurrenceRule =
        _safeString(_jsonValue(json, ['recurrence_rule', 'recurrenceRule']));
    final finalNotes = notes;
    _logger
      ..info(
        'Checklist from LLM: ${finalChecklist.length} items (trust model)',
      )
      ..info('Initial parsed values:')
      ..info('  title="$title"')
      ..info('  rawStartAt=${rawStartAt?.toIso8601String()}')
      ..info('  rawEndAt=${rawEndAt?.toIso8601String()}')
      ..info('  rawDeadlineAt=${rawDeadlineAt?.toIso8601String()}');
    /// эвристики перепарсинга и повторного извлечения дат убраны — доверяем датам модели
    final startAt = rawStartAt;
    final endAt = rawEndAt;
    final deadlineAt = rawDeadlineAt;
    var isAllDay = _safeBool(_jsonValue(json, ['is_all_day', 'isAllDay']));
    if (!isAllDay && startAt != null) {
      if (endAt == null &&
          (startAt.hour == 0 && startAt.minute == 0 && startAt.second == 0)) {
        isAllDay = true;
      }
    } else if (isAllDay && startAt != null) {
      if (!(startAt.hour == 0 && startAt.minute == 0 && startAt.second == 0)) {
        isAllDay = false;
      }
    }
    final rawEst =
        _safeInt(_jsonValue(json, ['est_min', 'estMin']), fallback: 30);
    final correctedEst = (rawEst * profile.correctionFactor).round();
    final estMin = correctedEst.clamp(5, 480);
    final parsedConfidence = _safeConfidence(_jsonValue(json, ['confidence']));
    final dto = TaskDTO(
      title: title,
      notes: finalNotes?.trim().isEmpty ?? true ? null : finalNotes!.trim(),
      startAt: startAt,
      endAt: endAt,
      deadlineAt: deadlineAt,
      isAllDay: isAllDay,
      estMin: estMin,
      priority: _safePriority(_jsonValue(json, ['priority'])),
      tags: _safeTags(_jsonValue(json, ['tags'])),
      checklistItems: finalChecklist,
      recurrenceRule: recurrenceRule?.trim().isEmpty ?? true
          ? null
          : recurrenceRule!.trim(),
      confidence: parsedConfidence.clamp(0.0, 1.0),
    );
    _logger.info(
      '═════ VALIDATION END: title="$title", startAt=${startAt?.toIso8601String()}, isAllDay=$isAllDay ═════',
    );
    return dto;
  }
  /// проверки placeholder-заголовков убраны
  /// эвристики повторного парсинга и санитизации дат убраны — доверяем выводу модели
  /// если не распарсили, кидаем ошибку
  /// маппинг качества убран — по умолчанию считаем вывод модели высококачественным
  String _safeTitle(Object? value, String fallbackText) {
    final fallback =
        fallbackText.trim().isEmpty ? 'Новая задача' : fallbackText.trim();
    var raw = _safeString(value) ?? fallback;
    _logger.fine('_safeTitle: raw="$raw", fallback="$fallback"');
    if (raw.isEmpty) {
      raw = fallback;
      _logger.fine('  Title was empty, using fallback: "$raw"');
    }
    if (raw.length <= 100) {
      _logger.fine('  ✓ Final title: "$raw"');
      return raw;
    }
    final truncated = raw.substring(0, 100);
    _logger.fine('  ✓ Final title (truncated): "$truncated"');
    return truncated;
  }
  /// эвристики извлечения времени убраны
  String? _safeString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }
  Object? _jsonValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (!json.containsKey(key)) {
        continue;
      }
      final value = json[key];
      if (value != null) {
        return value;
      }
    }
    return null;
  }
  DateTime? _safeDate(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }
  bool _safeBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.trim().toLowerCase() == 'true';
    }
    return false;
  }
  int _safeInt(Object? value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }
  double _safeConfidence(Object? value) {
    if (value is num) {
      return value.toDouble().clamp(0, 1);
    }
    if (value is String) {
      return (double.tryParse(value.trim()) ?? 1.0).clamp(0, 1);
    }
    /// по умолчанию считаем уверенность высокой
    return 1.0;
  }
  TaskPriority _safePriority(Object? value) {
    final normalized = (value ?? '').toString().toLowerCase();
    if (normalized == 'low') {
      return TaskPriority.low;
    }
    if (normalized == 'high') {
      return TaskPriority.high;
    }
    return TaskPriority.medium;
  }
  List<String> _safeTags(Object? value) {
    if (value is! List<Object?>) {
      return const <String>[];
    }
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .take(10)
        .toList(growable: false);
  }
  List<String> _safeStrings(Object? value, {required int limit}) {
    if (value is! List<Object?>) {
      return const <String>[];
    }
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .take(limit)
        .toList(growable: false);
  }
  Future<void> _appendErrorLog({
    required String userText,
    required String rawResponse,
    required String error,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/llm_errors.log');
    final entry = StringBuffer()
      ..writeln('ts=${DateTime.now().toIso8601String()}')
      ..writeln('userText=$userText')
      ..writeln('rawResponse=$rawResponse')
      ..writeln('error=$error')
      ..writeln('---');
    await file.writeAsString(
      entry.toString(),
      mode: FileMode.append,
      flush: true,
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
// ignore_for_file: prefer_const_declarations, require_trailing_commas
import '../../../core/llm/domain/ai_profile.dart';
import '../application/llm_response_parser.dart';
import '../application/prompt_builder.dart';
import '../domain/llm_service.dart';
class FlutterGemmaLLMService implements LLMService {
  FlutterGemmaLLMService();
  final Logger _logger = Logger('FlutterGemmaLLMService');
  final PromptBuilder _promptBuilder = PromptBuilder();
  final LLMResponseParser _responseParser = const LLMResponseParser();
  String get _gemmaModelAssetPath => 'assets/models/gemma-4-E2B-it.litertlm';
  String get _gemmaModelId => 'gemma-4-E2B-it.litertlm';
  ModelType get _gemmaModelType => ModelType.gemma4;
  static int get _gemmaMaxTokens {
    return 2048;
  }
  static Duration get _unloadDelay {
    if (Platform.isMacOS) return const Duration(minutes: 5);
    if (Platform.isIOS) return const Duration(minutes: 2);
    return const Duration(seconds: 30);
  }
  InferenceModel? _model;
  bool _initialized = false;
  Timer? _unloadTimer;
  Future<void>? _initializeFuture;
  @override
  String get activeBackend => _model?.activeBackend?.name ?? 'unknown';
  @override
  Future<void> initialize() {
    if (_initialized) {
      _logger.fine('FlutterGemma already initialized, skipping');
      return Future.value();
    }
    _initializeFuture ??= _initializeInternal().whenComplete(() {
      _initializeFuture = null;
    });
    return _initializeFuture!;
  }
  Future<void> _initializeInternal() async {
    try {
      _logger.info('Initializing FlutterGemma');
      await _appendDebugLog('INIT_START', {'ts': DateTime.now().toString()});
      _logger.info('Step 1: FlutterGemma.initialize()');
      await FlutterGemma.initialize(
        inferenceEngines: const [LiteRtLmEngine()],
      );
      _logger.info('Step 1 complete: FlutterGemma initialized');
      await _appendDebugLog('INIT_STEP1', {'status': 'done'});
      await _ensureActiveGemmaModel();
      _initialized = true;
      _logger.info('FlutterGemma initialization SUCCESSFUL');
      await _appendDebugLog('INIT_SUCCESS', {'ts': DateTime.now().toString()});
    } on Object catch (error, stackTrace) {
      _logger.severe('Failed to initialize FlutterGemma', error, stackTrace);
      await _appendDebugLog('INIT_ERROR', {
        'error': error.toString(),
        'type': error.runtimeType.toString(),
        'stack': stackTrace.toString().split('\n').take(5).join('\n'),
      });
      _initialized = false;
      _model = null;
      rethrow;
    }
  }
  Future<void> _ensureActiveGemmaModel() async {
    _logger.info('Step 2: Installing gemma model from assets');
    await _installGemmaModel();
    await _appendDebugLog('INIT_STEP2', {'status': 'model_installed'});
    try {
      _logger.info(
        'Step 3: Getting active model instance (may take time for native libs to load)',
      );
      _model = await _loadActiveGemmaModel();
      if (_model == null) {
        throw StateError('getActiveModel returned null after timeout was OK');
      }
      _logger.info('Step 3 complete: Active model ready');
      await _appendDebugLog('INIT_STEP3', {'status': 'model_ready'});
    } on Object catch (error, stackTrace) {
      final message = error.toString();
      final needsRepair =
          message.contains('Active model is no longer installed') ||
              message.contains('Model file validation failed');
      if (!needsRepair) {
        rethrow;
      }
      _logger.warning(
          'Gemma model is stale; repairing installation', error, stackTrace);
      await _appendDebugLog('INIT_REPAIR_START', {
        'error': message,
        'type': error.runtimeType.toString(),
      });
      await _repairGemmaModel();
      _model = await _loadActiveGemmaModel();
      if (_model == null) {
        throw StateError('getActiveModel returned null after repair');
      }
      _logger.info('Step 3 complete after repair: Active model ready');
      await _appendDebugLog('INIT_STEP3_REPAIRED', {'status': 'model_ready'});
    }
  }
  Future<void> _installGemmaModel() async {
    final builder = FlutterGemma.installModel(
      modelType: _gemmaModelType,
      fileType: ModelFileType.litertlm,
    );
    if (Platform.isMacOS) {
      final executable = Platform.resolvedExecutable;
      final contentsDir = File(executable).parent.parent.path;
      final absoluteAssetPath =
          '$contentsDir/Frameworks/App.framework/Resources/flutter_assets/$_gemmaModelAssetPath';
      _logger.info('Installing model from absolute path (macOS workaround): $absoluteAssetPath');
      await builder.fromFile(absoluteAssetPath).install();
    } else {
      await builder.fromAsset(_gemmaModelAssetPath).install();
    }
    _logger.info('Gemma model installation step complete');
  }
  Future<InferenceModel?> _loadActiveGemmaModel() async {
    return Future.delayed(Duration.zero, () async {
      try {
        _logger.fine('Calling FlutterGemma.getActiveModel()');
        final forceMacOptimization = Platform.isIOS || Platform.isMacOS;
        final preferredBackend = forceMacOptimization ? PreferredBackend.gpu : null;
        final m = await FlutterGemma.getActiveModel(
          maxTokens: _gemmaMaxTokens,
          preferredBackend: preferredBackend,
          enableSpeculativeDecoding: forceMacOptimization ? true : null,
        );
        _logger.fine(
          'getActiveModel returned: backend=$preferredBackend, mtp=$forceMacOptimization',
        );
        return m;
      } on Object catch (e, stackTrace) {
        _logger.severe('Error in getActiveModel', e, stackTrace);
        await _appendDebugLog('INIT_GET_MODEL_ERROR', {
          'error': e.toString(),
          'type': e.runtimeType.toString(),
          'stack': stackTrace.toString().split('\n').take(5).join('\n'),
        });
        rethrow;
      }
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        final err = 'Timeout waiting for getActiveModel (30s)';
        _logger.severe(err);
        throw TimeoutException(err);
      },
    );
  }
  Future<void> _repairGemmaModel() async {
    try {
      _logger.warning('Uninstalling stale Gemma model $_gemmaModelId');
      await FlutterGemma.uninstallModel(_gemmaModelId);
      await _appendDebugLog(
          'INIT_REPAIR_UNINSTALL', {'modelId': _gemmaModelId});
    } on Object catch (error, stackTrace) {
      _logger.warning(
          'Uninstall of stale model failed, continuing with reinstall',
          error,
          stackTrace);
      await _appendDebugLog('INIT_REPAIR_UNINSTALL_ERROR', {
        'error': error.toString(),
        'type': error.runtimeType.toString(),
        'stack': stackTrace.toString().split('\n').take(5).join('\n'),
      });
    }
    _logger.info('Reinstalling Gemma model from assets after repair');
    await _installGemmaModel();
    await _appendDebugLog('INIT_REPAIR_REINSTALL', {'status': 'done'});
  }
  Future<void> _appendDebugLog(String tag, Map<String, Object?> data) async {
    if (kReleaseMode) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/llm_debug.log');
      final entry = StringBuffer()
        ..writeln('ts=${DateTime.now().toIso8601String()}')
        ..writeln('tag=$tag')
        ..writeln(data.entries.map((e) => '${e.key}=${e.value}').join('\n'))
        ..writeln('---');
      await file.writeAsString(
        entry.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } on Object catch (e) {
      _logger.warning('Failed to append debug log: $e');
    }
  }
  @override
  Future<LLMParseResult> parseTask(String userText, AIProfile profile) async {
    try {
      _logger.info('parseTask: START (userText="$userText")');
      await _appendDebugLog('PARSE_TASK_START', {
        'userText': userText,
        'initialized': _initialized,
      });
      _logger.info('parseTask: Calling initialize()');
      await initialize();
      _logger.info('parseTask: initialize() DONE');
      if (_model == null) {
        _logger.severe('Model is unavailable after initialization');
        throw StateError('LLM model is unavailable');
      }
      _logger.info('parseTask: Building prompt');
      final prompt = _promptBuilder.build(
        userText,
        profile,
        DateTime.now(),
      );
      _logger.fine('parseTask: Prompt built (len=${prompt.length})');
      await _appendDebugLog('PROMPT', {
        'userText': userText,
        'prompt_len': prompt.length,
        'prompt_preview': prompt.substring(0, prompt.length.clamp(0, 1024)),
      });
      final responseObj = await _runPrompt(
        prompt,
        attemptLabel: 'first',
        tools: [_promptBuilder.createTaskTool()],
      );
      _logger.info('parseTask: Response received');
      await _appendDebugLog(
        'RESPONSE_TYPE',
        {'type': responseObj.runtimeType.toString()},
      );
      if (responseObj is FunctionCallResponse) {
        _logger.fine('FunctionCallResponse received: ${responseObj.name}');
        try {
          final args = responseObj.args;
          await _appendDebugLog('FUNCTION_CALL', {
            'name': responseObj.name,
            'args': args,
            'raw': responseObj.toString(),
          });
          final result = await _responseParser.parseFromMap(
            userText: userText,
            json: args,
            profile: profile,
            rawResponse: responseObj.toString(),
          );
          await _appendDebugLog('PARSED_TASK', {
            'userText': userText,
            'title': result.task.title,
            'startAt': result.task.startAt?.toIso8601String(),
            'endAt': result.task.endAt?.toIso8601String(),
            'deadlineAt': result.task.deadlineAt?.toIso8601String(),
            'isAllDay': result.task.isAllDay,
            'estMin': result.task.estMin,
            'priority': result.task.priority.toString(),
            'tags': result.task.tags,
            'recurrenceRule': result.task.recurrenceRule,
            'confidence': result.task.confidence,
            'rawResponse': result.rawResponse ?? responseObj.toString(),
          });
          return result;
        } on Object catch (e, stack) {
          _logger.severe('Error parsing FunctionCallResponse', e, stack);
          await _appendDebugLog('FUNCTION_CALL_PARSE_ERROR', {
            'error': e.toString(),
            'stack': stack.toString(),
            'raw': responseObj.toString(),
          });
          final result = await _responseParser.parse(
            userText: userText,
            rawResponse: responseObj.toString(),
            profile: profile,
          );
          await _appendDebugLog('PARSED_TASK', {
            'userText': userText,
            'title': result.task.title,
            'startAt': result.task.startAt?.toIso8601String(),
            'endAt': result.task.endAt?.toIso8601String(),
            'deadlineAt': result.task.deadlineAt?.toIso8601String(),
            'isAllDay': result.task.isAllDay,
            'estMin': result.task.estMin,
            'priority': result.task.priority.toString(),
            'tags': result.task.tags,
            'recurrenceRule': result.task.recurrenceRule,
            'confidence': result.task.confidence,
            'rawResponse': result.rawResponse ?? responseObj.toString(),
          });
          return result;
        }
      }
      final raw = responseObj is TextResponse
          ? responseObj.token
          : responseObj.toString();
      await _appendDebugLog('TEXT_RESPONSE', {
        'len': raw.length,
        'preview': raw.substring(0, raw.length.clamp(0, 2048)),
      });
      _logger.fine('Parsing text response (len=${raw.length})');
      final result = await _responseParser.parse(
        userText: userText,
        rawResponse: raw,
        profile: profile,
      );
      await _appendDebugLog('PARSED_TASK', {
        'userText': userText,
        'title': result.task.title,
        'startAt': result.task.startAt?.toIso8601String(),
        'endAt': result.task.endAt?.toIso8601String(),
        'deadlineAt': result.task.deadlineAt?.toIso8601String(),
        'isAllDay': result.task.isAllDay,
        'estMin': result.task.estMin,
        'priority': result.task.priority.toString(),
        'tags': result.task.tags,
        'recurrenceRule': result.task.recurrenceRule,
        'confidence': result.task.confidence,
        'rawResponse': result.rawResponse ?? raw,
      });
      _logger.info(
          'parseTask: SUCCESS - returning task "${result.task.title}" with startAt=${result.task.startAt}');
      return result;
    } on Object catch (error, stackTrace) {
      _logger.severe('gemma_parse_failed', error, stackTrace);
      rethrow;
    }
  }
  Future<ModelResponse> _runPrompt(
    String prompt, {
    required String attemptLabel,
    List<Tool> tools = const [],
  }) async {
    _logger
        .fine('_runPrompt: $attemptLabel START (prompt_len=${prompt.length})');
    _resetUnloadTimer();
    await _appendDebugLog('PROMPT_START', {
      'attempt': attemptLabel,
      'model_initialized': _initialized,
      'model_null': _model == null,
    });
    if (_model == null) {
      throw StateError('Model is null in _runPrompt');
    }
    _logger.fine('Creating chat with temperature=0.2, topK=20');
    final chat = await _model!.createChat(
      temperature: 0.2,
      randomSeed: DateTime.now().microsecondsSinceEpoch & 0x7fffffff,
      topK: 20,
      tools: tools,
      toolChoice: tools.isNotEmpty ? ToolChoice.required : ToolChoice.auto,
    );
    try {
      _logger.fine('Adding query message to chat');
      await chat.addQuery(Message.text(text: prompt));
      _logger.fine('Generating chat response...');
      await _appendDebugLog(
          'BEFORE_GENERATE', {'status': 'calling_generateChatResponse'});
      final response = await chat.generateChatResponse().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          final err = 'Timeout waiting for generateChatResponse (60s)';
          _logger.severe(err);
          throw TimeoutException(err);
        },
      );
      _logger.fine(
        '_runPrompt: $attemptLabel response: ${response.runtimeType}',
      );
      await _appendDebugLog('PROMPT_SUCCESS', {
        'attempt': attemptLabel,
        'response_type': response.runtimeType.toString(),
        'response_class': response.toString().split('(').first,
      });
      return response;
    } on TimeoutException catch (e) {
      _logger.severe('Timeout in _runPrompt: $e');
      await _appendDebugLog('PROMPT_TIMEOUT', {
        'attempt': attemptLabel,
        'error': e.toString(),
      });
      rethrow;
    } catch (e) {
      _logger.severe('Error in _runPrompt: $e');
      await _appendDebugLog('PROMPT_ERROR', {
        'attempt': attemptLabel,
        'error': e.toString(),
        'type': e.runtimeType.toString(),
      });
      rethrow;
    } finally {
      _logger.fine('Closing chat');
      await chat.close();
      _logger.fine('Chat closed');
      _scheduleUnload();
    }
  }
  @override
  Future<void> warmup() async {
    try {
      _logger.info('warmup: предзагрузка модели в GPU-память');
      await initialize();
      _scheduleUnload();
    } on Object catch (e) {
      _logger.warning('warmup: не удалось предзагрузить модель', e);
    }
  }
  void _resetUnloadTimer() {
    _unloadTimer?.cancel();
    _unloadTimer = null;
  }
  void _scheduleUnload() {
    _resetUnloadTimer();
    _unloadTimer = Timer(_unloadDelay, () async {
      _logger.info(
          'Авто-выгрузка: освобождаем GPU-память ($_unloadDelay без запросов)');
      try {
        await _model?.close();
      } on Object catch (e) {
        _logger.warning('Ошибка при авто-выгрузке модели', e);
      }
      _model = null;
      _initialized = false;
      await _appendDebugLog('AUTO_UNLOAD', {'ts': DateTime.now().toString()});
    });
  }
  @override
  Future<void> dispose() async {
    _resetUnloadTimer();
    try {
      await _model?.close();
    } on Object catch (e) {
      _logger.warning('Error closing model', e);
    }
    _model = null;
    _initialized = false;
  }
}

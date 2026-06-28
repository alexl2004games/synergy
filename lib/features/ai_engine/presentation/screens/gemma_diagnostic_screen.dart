import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/llm/domain/ai_profile.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/liquid_background.dart';
import '../../application/prompt_builder.dart';
import '../../application/llm_service_provider.dart';
import '../../domain/llm_service.dart';
import '../../../tasks/presentation/providers/task_creation_controller.dart';
import '../../../tasks/domain/task.dart' as task_domain;
class GemmaDiagnosticScreen extends ConsumerStatefulWidget {
  const GemmaDiagnosticScreen({super.key});
  @override
  ConsumerState<GemmaDiagnosticScreen> createState() =>
      _GemmaDiagnosticScreenState();
}
class _GemmaDiagnosticScreenState extends ConsumerState<GemmaDiagnosticScreen> {
  final TextEditingController _queryController = TextEditingController(
    text:
        'завтра купить хлеб, молоко, сыр и помыть машину до 18:00, займет 45 минут',
  );
  bool _isLoading = false;
  String? _error;
  String? _userQuery;
  String? _generatedPrompt;
  String? _rawLlmResponse;
  TaskDTO? _parsedDto;
  AIProfile? _aiProfile;
  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
  Future<AIProfile> _readAiProfile() async {
    final row = await ref.read(databaseProvider).aiProfileDao.getProfile();
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
  Future<void> _runDiagnostic() async {
    final queryText = _queryController.text.trim();
    if (queryText.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _userQuery = queryText;
      _generatedPrompt = null;
      _rawLlmResponse = null;
      _parsedDto = null;
      _aiProfile = null;
    });
    try {
      final profile = await _readAiProfile();
      final promptBuilder = PromptBuilder();
      final generatedPrompt = promptBuilder.build(
        queryText,
        profile,
        DateTime.now(),
      );
      final llmService = ref.read(llmServiceProvider);
      final result = await llmService.parseTask(queryText, profile);
      setState(() {
        _generatedPrompt = generatedPrompt;
        _rawLlmResponse = result.rawResponse ??
            'Ответ в формате FunctionCall / структурированный объект';
        _parsedDto = result.task;
        _aiProfile = profile;
        _isLoading = false;
      });
    } on Object catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  Future<void> _saveTaskToDatabase() async {
    final dto = _parsedDto;
    final query = _userQuery;
    if (dto == null || query == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final request = TaskCreationRequest(
        text: dto.title,
        notes: dto.notes ?? '',
        checklistItems: dto.checklistItems,
        isToday: dto.startAt != null &&
            DateUtils.isSameDay(dto.startAt, DateTime.now()),
        useLlm: false,
        startAt: dto.startAt,
        deadlineAt: dto.deadlineAt,
        isAllDay: dto.isAllDay,
        recurrenceRule: dto.recurrenceRule,
        estMin: dto.estMin,
      );
      await ref.read(taskCreationControllerProvider.notifier).create(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Задача успешно сохранена в базу данных и расписание!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Stack(
      children: [
        const Positioned.fill(child: LiquidBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: BackButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/settings');
                }
              },
            ),
            title: const Text('Тест NLP'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Введите тестовый запрос на естественном языке:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _queryController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Например: Завтра в 12:00 сходить к врачу...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.black12 : Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _runDiagnostic,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.psychology),
                        label: Text(
                          _isLoading
                              ? 'Анализ...'
                              : 'Запустить тест NLP',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                GlassContainer(
                  bgOpacity: 0.15,
                  borderOpacity: 0.3,
                  child: ListTile(
                    leading: const Icon(Icons.error_outline, color: Colors.red),
                    title: const Text('Ошибка при выполнении запроса'),
                    subtitle: Text(_error!),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (_parsedDto != null) ...[
                Text(
                  '1. Результаты разбора TaskDTO',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultRow(
                        'Заголовок (Title)',
                        _parsedDto!.title,
                        context,
                      ),
                      _buildResultRow(
                        'Заметки (Notes)',
                        _parsedDto!.notes ?? '—',
                        context,
                      ),
                      _buildResultRow(
                        'Время старта (Start At)',
                        _parsedDto!.startAt?.toIso8601String() ?? '—',
                        context,
                        color: _parsedDto!.startAt != null ? Colors.cyan : null,
                      ),
                      _buildResultRow(
                        'Время окончания (End At)',
                        _parsedDto!.endAt?.toIso8601String() ?? '—',
                        context,
                        color: _parsedDto!.endAt != null ? Colors.cyan : null,
                      ),
                      _buildResultRow(
                        'Дедлайн (Deadline At)',
                        _parsedDto!.deadlineAt?.toIso8601String() ?? '—',
                        context,
                        color: _parsedDto!.deadlineAt != null
                            ? Colors.amber
                            : null,
                      ),
                      _buildResultRow(
                        'На весь день (Is All Day)',
                        _parsedDto!.isAllDay ? 'Да' : 'Нет',
                        context,
                        color: _parsedDto!.isAllDay ? Colors.teal : null,
                      ),
                      _buildResultRow(
                        'Длительность (Est Min)',
                        '${_parsedDto!.estMin} минут (базовая оценка, скорректированная фактором ${_aiProfile?.correctionFactor ?? 1.0})',
                        context,
                      ),
                      _buildResultRow(
                        'Приоритет (Priority)',
                        _parsedDto!.priority
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        context,
                        color: _parsedDto!.priority ==
                                task_domain.TaskPriority.high
                            ? Colors.redAccent
                            : (_parsedDto!.priority ==
                                    task_domain.TaskPriority.medium
                                ? Colors.orangeAccent
                                : Colors.blueAccent),
                      ),
                      _buildResultRow(
                        'Правило повторения (Recurrence)',
                        _parsedDto!.recurrenceRule ?? '—',
                        context,
                      ),
                      _buildResultRow(
                        'Уверенность (Confidence)',
                        '${(_parsedDto!.confidence * 100).toStringAsFixed(1)}%',
                        context,
                      ),
                      if (_parsedDto!.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Теги (Tags):',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: _parsedDto!.tags
                              .map(
                                (tag) => Chip(
                                  label: Text(tag),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (_parsedDto!.checklistItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Автоматический Чек-лист (Checklist Items):',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        ..._parsedDto!.checklistItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_box_outlined,
                                  size: 20,
                                  color: Colors.purpleAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(item, style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  bgOpacity: 0.12,
                  child: Row(
                    children: [
                      const Icon(Icons.storage, color: Colors.greenAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Симуляция записи в базу данных',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Нажмите, чтобы конвертировать DTO в доменную сущность Drift и поместить в календарь.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _isLoading ? null : _saveTaskToDatabase,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                        child: const Text('Сохранить'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildCollapseSection(
                  title: '2. Сгенерированный системный промпт (Prompt)',
                  content: _generatedPrompt ?? '',
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _buildCollapseSection(
                  title: '3. Сырой ответ Gemma 4 (Raw Response)',
                  content: _rawLlmResponse ?? '',
                  theme: theme,
                  isCode: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildResultRow(
    String label,
    String value,
    BuildContext context, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: color != null ? FontWeight.bold : null,
            ),
          ),
          const Divider(height: 12, thickness: 0.5),
        ],
      ),
    );
  }
  Widget _buildCollapseSection({
    required String title,
    required String content,
    required ThemeData theme,
    bool isCode = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.all(12),
          child: ExpansionTile(
            title: Text(
              isCode ? 'Показать JSON' : 'Показать промпт',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

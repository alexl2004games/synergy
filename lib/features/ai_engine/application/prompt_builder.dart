import 'package:flutter_gemma/flutter_gemma.dart';
import '../../../core/llm/domain/ai_profile.dart';
class PromptBuilder {
  String build(String userText, AIProfile profile, DateTime now) {
    final weekDaysRu = [
      'понедельник',
      'вторник',
      'среда',
      'четверг',
      'пятница',
      'суббота',
      'воскресенье',
    ];
    final monthsRu = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    final today = now.toIso8601String().split('T')[0];
    final weekday = weekDaysRu[now.weekday - 1];
    final monthName = monthsRu[now.month - 1];
    final nextMonthName = monthsRu[now.month % 12];
    final nextMonthNum = (now.month % 12) + 1;
    final upcomingDays = List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      final w = weekDaysRu[date.weekday - 1];
      final d = date.toIso8601String().split('T')[0];
      return '$w=$d';
    }).join(', ');
    final prompt = '''
You are an NLP parser. Extract structured tasks from user text by calling the `create_tasks` tool.
TODAY: $today ($weekday, $monthName). NEXT MONTH: $nextMonthName (month #$nextMonthNum).
Upcoming week: $upcomingDays
TEXT: "$userText"
Rules:
- MUST use the EXACT SAME LANGUAGE as TEXT for title, notes, tags and checklist_items. DO NOT translate to English!
- `start_at` (ISO8601): The date/time the task EXECUTION begins. Compute relative to TODAY.
- `deadline_at` (ISO8601): The deadline or target event date (e.g., "до пятницы", "на пятницу").
- CRITICAL for `start_at` vs `deadline_at`:
  1. If the task is about PREPARING or BOOKING something for a future date (e.g. "записать кота на пятницу", "купить билеты к среде"), the action must be done NOW. Set `start_at` to TODAY, and `deadline_at` to the future date.
  2. If the task is an EVENT or ACTION that actually happens ON that future date (e.g. "поехать в ресторан в пятницу", "встретиться на выходных"), set `start_at` to THAT FUTURE DATE.
- You MUST COMPLETELY STRIP all recurrence markers and temporal markers from the `title`.
- title = pure actionable intent ONLY (e.g. "Покормить голубей", "Сходить в магазин"). Preserve grammatically correct verb forms. NEVER list specific items or sub-tasks in the title. 
- MUST extract recurrence logic into recurrence_rule (e.g. "каждый день"→RRULE:FREQ=DAILY, "каждую неделю"→RRULE:FREQ=WEEKLY).
- Tags in TEXT language. Max 2. Broad only. Never use items like "пиво","хлеб" as tags
- "утром"→09:00, "в обед"→12:00, "вечером"→18:00 (is_all_day=false)
- Date only without time → is_all_day=true, start_at=date at 00:00
- 'checklist_items': MUST extract all secondary actions, sub-tasks, or items to prepare (e.g. "забрать новую переноску", "взять паспорт") into this array. Do NOT leave them in the title or notes!
- 'notes': extra context ONLY. DO NOT just copy the raw user text here! If there are no extra details left after extracting checklist items and temporal markers, return null.
''';
    return prompt;
  }
  Tool createTaskTool() {
    return const Tool(
      name: 'create_tasks',
      description: 'Creates structured tasks from user intent',
      parameters: {
        'type': 'OBJECT',
        'properties': {
          'tasks': {
            'type': 'ARRAY',
            'items': {
              'type': 'OBJECT',
              'properties': {
                'title': {'type': 'STRING', 'description': 'PURE actionable intent. Absolutely NO temporal words (завтра, в обед) and NO recurrence words (каждую неделю).'},
                'notes': {'type': 'STRING', 'description': 'Extract any notes, descriptions or заметка: ... Otherwise null.', 'nullable': true},
                'start_at': {'type': 'STRING', 'description': 'ISO8601 string. The date when task execution begins. Distinguish between booking/prep (starts TODAY) vs actual future events (starts on the target date).', 'nullable': true},
                'deadline_at': {'type': 'STRING', 'description': 'ISO8601 string. Extract deadline or target date if user says до X, к X, на X (e.g. на пятницу). Otherwise null.', 'nullable': true},
                'is_all_day': {'type': 'BOOLEAN'},
                'est_min': {'type': 'INTEGER', 'description': 'Estimated duration in minutes (default 30)'},
                'priority': {'type': 'STRING', 'enum': ['low', 'medium', 'high']},
                'tags': {
                  'type': 'ARRAY',
                  'items': {'type': 'STRING'},
                },
                'checklist_items': {
                  'type': 'ARRAY',
                  'items': {'type': 'STRING'},
                },
                'recurrence_rule': {'type': 'STRING', 'description': 'RFC5545 RRULE format (e.g. RRULE:FREQ=MONTHLY, RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR). Extract if user says повторять каждый месяц, каждую неделю. Otherwise null.', 'nullable': true},
                'confidence': {'type': 'NUMBER'},
              },
              'required': ['title', 'notes', 'start_at', 'deadline_at', 'is_all_day', 'est_min', 'priority', 'recurrence_rule', 'confidence'],
            },
          },
        },
        'required': ['tasks'],
      },
    );
  }
}

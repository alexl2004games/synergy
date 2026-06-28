import '../../../core/llm/domain/ai_profile.dart';
class CommandPromptBuilder {
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
    final today = now.toIso8601String().split('T')[0];
    final weekday = weekDaysRu[now.weekday - 1];
    return '''
You are an NLP parser for task commands.
TODAY: $today ($weekday)
TEXT: "$userText"
Return ONLY valid JSON:
{"action":"execute_commands",
"commands":[{"type":"create_tasks|edit_task|delete_task|complete_task|rebalance_day",
"target_task_title":"string|null","changes":{"title":"string|null","notes":"string|null",
"start_at":"ISO8601|null","deadline_at":"ISO8601|null","est_min":int|null,
"priority":"low|medium|high|null","is_pinned":bool|null}}],
"tasks":[{"title":"string","notes":"string|null","start_at":"ISO8601|null",
"end_at":"ISO8601|null","deadline_at":"ISO8601|null","is_all_day":bool,
"est_min":int,"priority":"low|medium|high","tags":["strings"],
"checklist_items":["strings"],"recurrence_rule":"RRULE|null","confidence":float}]}
Rules:
- Compute dates from TODAY. "утром"→09:00, "в обед"→12:00, "вечером"→18:00
- Date only → is_all_day=true, start_at=date at 00:00
- If user specifies a future target/deadline (e.g. "записать на пятницу", "к среде"), set deadline_at to that date. If no start date is given, set start_at to TODAY to allow preparation.
- 'title': concise main goal only. Exclude dates, time, and subtasks.
- 'checklist_items': actionable sub-tasks only. Do NOT repeat the main title.
- 'notes': extra context only. Do NOT copy raw input. Set to null if redundant.
''';
  }
}

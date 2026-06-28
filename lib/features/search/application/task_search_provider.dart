import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../tasks/data/drift_checklist_repository.dart';
import '../../tasks/data/drift_task_tag_repository.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_checklist_item.dart';
import '../../tasks/domain/task_tag.dart';
import '../../tasks/presentation/providers/task_views_provider.dart';
import '../../tasks/presentation/providers/tasks_provider.dart';
final taskSearchQueryProvider =
    StateNotifierProvider<_TaskSearchQueryController, String>(
  (ref) => _TaskSearchQueryController(),
);
class _TaskSearchQueryController extends StateNotifier<String> {
  _TaskSearchQueryController() : super('');
  String get query => state;
  set query(String value) => state = value;
}
final allChecklistItemsProvider =
    StreamProvider<List<TaskChecklistItem>>((ref) {
  final dao = ref.watch(tasksDaoProvider);
  return dao.select(dao.taskChecklistItems).watch().map(
        (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
      );
});
final allTaskTagsProvider = StreamProvider<List<TaskTag>>((ref) {
  final dao = ref.watch(tasksDaoProvider);
  return dao.select(dao.taskTags).watch().map(
        (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
      );
});
final taskSearchResultsProvider = Provider<List<Task>>((ref) {
  final rawQuery = ref.watch(taskSearchQueryProvider).trim();
  final allTasks = ref.watch(allTasksProvider).value ?? const <Task>[];
  final uniqueTasks = <Task>[];
  final seenOriginalIds = <String>{};
  for (final task in allTasks) {
    final key = task.parentTaskId ?? task.id;
    if (!seenOriginalIds.contains(key)) {
      seenOriginalIds.add(key);
      uniqueTasks.add(task);
    }
  }
  final tasks = uniqueTasks;
  final checklistItems =
      ref.watch(allChecklistItemsProvider).value ?? const <TaskChecklistItem>[];
  final tags = ref.watch(allTaskTagsProvider).value ?? const <TaskTag>[];
  final now = DateTime.now();
  if (rawQuery.isEmpty) {
    final active = tasks
        .where(
          (t) =>
              t.status != TaskStatus.completed &&
              t.status != TaskStatus.cancelled,
        )
        .toList(growable: false);
    if (active.isNotEmpty) {
      active.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return active.take(20).toList(growable: false);
    }
    final completed = tasks
        .where((t) => t.status == TaskStatus.completed)
        .toList(growable: false)
      ..sort((a, b) {
        final aCompleted =
            a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bCompleted =
            b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bCompleted.compareTo(aCompleted);
      });
    return completed.take(20).toList(growable: false);
  }
  final parsedQuery = _parseSearchQuery(rawQuery, now);
  final checklistByTaskId = <String, List<String>>{};
  for (final item in checklistItems) {
    checklistByTaskId
        .putIfAbsent(item.taskId, () => <String>[])
        .add(item.title);
  }
  final tagsByTaskId = <String, List<String>>{};
  for (final tag in tags) {
    tagsByTaskId.putIfAbsent(tag.taskId, () => <String>[]).add(tag.tagName);
  }
  final scoredTasks = <_ScoredTask>[];
  for (final task in tasks) {
    final score = _scoreTask(
      task,
      parsedQuery,
      checklistByTaskId[task.id] ?? const <String>[],
      tagsByTaskId[task.id] ?? const <String>[],
    );
    if (score > 0) {
      scoredTasks.add(_ScoredTask(task: task, score: score));
    }
  }
  scoredTasks.sort(
    (a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return b.task.updatedAt.compareTo(a.task.updatedAt);
    },
  );
  return scoredTasks.map((entry) => entry.task).toList(growable: false);
});
class _ScoredTask {
  const _ScoredTask({required this.task, required this.score});
  final Task task;
  final int score;
}
class _ParsedSearchQuery {
  const _ParsedSearchQuery({required this.textQuery, this.dateFilter});
  final String textQuery;
  final _DateFilter? dateFilter;
}
enum _DateFilterType { exact, monthDay, weekday }
class _DateFilter {
  const _DateFilter.exact(this.date)
      : type = _DateFilterType.exact,
        month = null,
        day = null,
        weekday = null;
  const _DateFilter.monthDay(this.month, this.day)
      : type = _DateFilterType.monthDay,
        date = null,
        weekday = null;
  const _DateFilter.weekday(this.weekday)
      : type = _DateFilterType.weekday,
        date = null,
        month = null,
        day = null;
  final _DateFilterType type;
  final DateTime? date;
  final int? month;
  final int? day;
  final int? weekday;
}
int _scoreTask(
  Task task,
  _ParsedSearchQuery parsedQuery,
  List<String> checklistItems,
  List<String> tagNames,
) {
  final textQuery = parsedQuery.textQuery;
  final title = _normalizeText(task.title);
  final notes = _normalizeText(task.notes);
  final checklistText = _normalizeText(checklistItems.join(' '));
  final tagsText = _normalizeText(tagNames.join(' '));
  final haystack = [title, notes, checklistText, tagsText].join(' ').trim();
  var score = 0;
  if (parsedQuery.dateFilter != null) {
    if (!_taskMatchesDate(task, parsedQuery.dateFilter!)) {
      return 0;
    }
    score += 100;
  }
  if (textQuery.isEmpty) {
    return score + _recencyScore(task);
  }
  if (title.contains(textQuery)) {
    score += 80;
  }
  if (notes.contains(textQuery)) {
    score += 60;
  }
  if (checklistText.contains(textQuery)) {
    score += 65;
  }
  if (tagsText.contains(textQuery)) {
    score += 55;
  }
  if (haystack.contains(textQuery)) {
    score += 35;
  }
  final tokens = textQuery
      .split(' ')
      .map((token) => token.trim())
      .where((token) => token.isNotEmpty)
      .toList(growable: false);
  for (final token in tokens) {
    if (title.contains(token)) {
      score += 18;
    } else if (checklistText.contains(token)) {
      score += 14;
    } else if (tagsText.contains(token)) {
      score += 12;
    } else if (notes.contains(token)) {
      score += 10;
    } else if (haystack.contains(token)) {
      score += 6;
    }
  }
  if (score == 0) {
    return 0;
  }
  return score;
}
int _recencyScore(Task task) {
  final reference = task.updatedAt;
  final ageDays = DateTime.now().difference(reference).inDays;
  return (50 - ageDays).clamp(0, 50);
}
bool _taskMatchesDate(Task task, _DateFilter filter) {
  final candidates = <DateTime>[
    if (task.startAt != null) task.startAt!,
    if (task.deadlineAt != null) task.deadlineAt!,
  ];
  if (candidates.isEmpty) {
    return false;
  }
  for (final candidate in candidates) {
    switch (filter.type) {
      case _DateFilterType.exact:
        if (filter.date == null) {
          continue;
        }
        if (_sameDay(candidate, filter.date!)) {
          return true;
        }
      case _DateFilterType.monthDay:
        if (filter.month == null || filter.day == null) {
          continue;
        }
        if (candidate.month == filter.month && candidate.day == filter.day) {
          return true;
        }
      case _DateFilterType.weekday:
        if (filter.weekday == null) {
          continue;
        }
        if (candidate.weekday == filter.weekday) {
          return true;
        }
    }
  }
  return false;
}
bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
_ParsedSearchQuery _parseSearchQuery(String query, DateTime now) {
  var remaining = query.toLowerCase().replaceAll('ё', 'е').trim();
  _DateFilter? filter;
  String? consume(RegExp pattern) {
    final match = pattern.firstMatch(remaining);
    if (match == null) {
      return null;
    }
    remaining = remaining.replaceFirst(match.group(0)!, ' ');
    return match.group(0);
  }
  final relativePatterns = <MapEntry<RegExp, _DateFilter Function()>>[
    MapEntry(
      RegExp(r'(?<!\S)(сегодня|today)(?!\S)'),
      () => _DateFilter.exact(_dateOnly(now)),
    ),
    MapEntry(
      RegExp(r'(?<!\S)(завтра|tomorrow)(?!\S)'),
      () => _DateFilter.exact(_dateOnly(now.add(const Duration(days: 1)))),
    ),
    MapEntry(
      RegExp(r'(?<!\S)(послезавтра|day after tomorrow)(?!\S)'),
      () => _DateFilter.exact(_dateOnly(now.add(const Duration(days: 2)))),
    ),
    MapEntry(
      RegExp(r'(?<!\S)(вчера|yesterday)(?!\S)'),
      () => _DateFilter.exact(
        _dateOnly(now.subtract(const Duration(days: 1))),
      ),
    ),
  ];
  for (final entry in relativePatterns) {
    if (entry.key.hasMatch(remaining)) {
      consume(entry.key);
      filter = entry.value();
      break;
    }
  }
  if (filter == null) {
    final weekdayPatterns = <MapEntry<RegExp, int>>[
      MapEntry(RegExp(r'(?<!\S)(понедельник|monday)(?!\S)'), DateTime.monday),
      MapEntry(RegExp(r'(?<!\S)(вторник|tuesday)(?!\S)'), DateTime.tuesday),
      MapEntry(RegExp(r'(?<!\S)(среда|wednesday)(?!\S)'), DateTime.wednesday),
      MapEntry(RegExp(r'(?<!\S)(четверг|thursday)(?!\S)'), DateTime.thursday),
      MapEntry(RegExp(r'(?<!\S)(пятница|friday)(?!\S)'), DateTime.friday),
      MapEntry(RegExp(r'(?<!\S)(суббота|saturday)(?!\S)'), DateTime.saturday),
      MapEntry(RegExp(r'(?<!\S)(воскресенье|sunday)(?!\S)'), DateTime.sunday),
    ];
    for (final entry in weekdayPatterns) {
      if (!entry.key.hasMatch(remaining)) {
        continue;
      }
      consume(entry.key);
      filter = _DateFilter.weekday(entry.value);
      break;
    }
  }
  if (filter == null) {
    final exactDate = RegExp(
      r'(?<!\S)(\d{1,2})[./-](\d{1,2})(?:[./-](\d{2,4}))?(?!\S)',
    ).firstMatch(remaining);
    if (exactDate != null) {
      final day = int.tryParse(exactDate.group(1) ?? '');
      final month = int.tryParse(exactDate.group(2) ?? '');
      final year = _parseYear(exactDate.group(3));
      if (day != null && month != null) {
        filter = year == null
            ? _DateFilter.monthDay(month, day)
            : _DateFilter.exact(DateTime(year, month, day));
        remaining = remaining.replaceFirst(exactDate.group(0)!, ' ');
      }
    }
  }
  if (filter == null) {
    final monthDate = RegExp(
      r'(?<!\S)(\d{1,2})\s+(января|янв|january|jan|февраля|фев|february|feb|марта|мар|march|mar|апреля|апр|april|apr|мая|may|июня|июн|june|jun|июля|июл|july|jul|августа|авг|august|aug|сентября|сен|september|sep|октября|окт|october|oct|ноября|ноя|november|nov|декабря|дек|december|dec)(?!\S)',
    ).firstMatch(remaining);
    if (monthDate != null) {
      final day = int.tryParse(monthDate.group(1) ?? '');
      final month = _parseMonth(monthDate.group(2));
      if (day != null && month != null) {
        filter = _DateFilter.monthDay(month, day);
        remaining = remaining.replaceFirst(monthDate.group(0)!, ' ');
      }
    }
  }
  final textQuery = _normalizeText(remaining);
  return _ParsedSearchQuery(textQuery: textQuery, dateFilter: filter);
}
DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
int? _parseYear(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final year = int.tryParse(value);
  if (year == null) {
    return null;
  }
  return year < 100 ? 2000 + year : year;
}
int? _parseMonth(String? value) {
  if (value == null) {
    return null;
  }
  switch (value) {
    case 'января':
    case 'янв':
    case 'january':
    case 'jan':
      return 1;
    case 'февраля':
    case 'фев':
    case 'february':
    case 'feb':
      return 2;
    case 'марта':
    case 'мар':
    case 'march':
    case 'mar':
      return 3;
    case 'апреля':
    case 'апр':
    case 'april':
    case 'apr':
      return 4;
    case 'мая':
    case 'may':
      return 5;
    case 'июня':
    case 'июн':
    case 'june':
    case 'jun':
      return 6;
    case 'июля':
    case 'июл':
    case 'july':
    case 'jul':
      return 7;
    case 'августа':
    case 'авг':
    case 'august':
    case 'aug':
      return 8;
    case 'сентября':
    case 'сен':
    case 'september':
    case 'sep':
      return 9;
    case 'октября':
    case 'окт':
    case 'october':
    case 'oct':
      return 10;
    case 'ноября':
    case 'ноя':
    case 'november':
    case 'nov':
      return 11;
    case 'декабря':
    case 'дек':
    case 'december':
    case 'dec':
      return 12;
    default:
      return null;
  }
}
String _normalizeText(String text) {
  return text
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(RegExp('[^a-zа-я0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

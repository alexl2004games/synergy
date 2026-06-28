class RussianDateParser {
  static const _months = {
    'январ': 1,
    'февр': 2,
    'март': 3,
    'апр': 4,
    'май': 5,
    'июнь': 6,
    'июль': 7,
    'август': 8,
    'сентябр': 9,
    'октябр': 10,
    'ноябр': 11,
    'декабр': 12,
  };
  static DateTime? parseRussianDate(String text, DateTime baseDate) {
    final normalized = text.trim().toLowerCase();
    final match = RegExp(r'(\d{1,2})\s+([а-яё]+)').firstMatch(normalized);
    if (match == null) {
      return null;
    }
    final dayStr = match.group(1);
    final monthStr = match.group(2);
    if (dayStr == null || monthStr == null) {
      return null;
    }
    final day = int.tryParse(dayStr);
    if (day == null || day < 1 || day > 31) {
      return null;
    }
    int? month;
    for (final entry in _months.entries) {
      if (monthStr.startsWith(entry.key)) {
        month = entry.value;
        break;
      }
    }
    if (month == null) {
      return null;
    }
    try {
      return DateTime(baseDate.year, month, day);
    } on Exception {
      return null;
    }
  }
  static DateTime? parseRussianDatetime(String text, DateTime baseDate) {
    final timeMatch = RegExp(r'в\s+(\d{1,2}):(\d{2})').firstMatch(text);
    if (timeMatch == null) {
      final date = parseRussianDate(text, baseDate);
      if (date == null) {
        return null;
      }
      return DateTime(date.year, date.month, date.day, 12);
    }
    final hourStr = timeMatch.group(1);
    final minStr = timeMatch.group(2);
    if (hourStr == null || minStr == null) {
      return null;
    }
    final hour = int.tryParse(hourStr);
    final minute = int.tryParse(minStr);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    final dateText = text.replaceAll(RegExp(r'в\s+\d{1,2}:\d{2}'), '');
    final date = parseRussianDate(dateText, baseDate);
    if (date == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
  static String? tryParseToIso8601(String text, DateTime baseDate) {
    final parsed = parseRussianDatetime(text, baseDate);
    if (parsed == null) {
      return null;
    }
    return parsed.toIso8601String();
  }
}

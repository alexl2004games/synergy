import 'package:flutter/material.dart';
class WorkWindow {
  const WorkWindow({
    this.weekdayStart = const TimeOfDay(hour: 9, minute: 0),
    this.weekdayEnd = const TimeOfDay(hour: 18, minute: 0),
    this.weekendStart = const TimeOfDay(hour: 10, minute: 0),
    this.weekendEnd = const TimeOfDay(hour: 16, minute: 0),
  });
  const WorkWindow.defaults()
      : this(
          weekdayStart: const TimeOfDay(hour: 9, minute: 0),
          weekdayEnd: const TimeOfDay(hour: 18, minute: 0),
          weekendStart: const TimeOfDay(hour: 10, minute: 0),
          weekendEnd: const TimeOfDay(hour: 16, minute: 0),
        );
  factory WorkWindow.fromMinutes({
    required int weekdayStart,
    required int weekdayEnd,
    required int weekendStart,
    required int weekendEnd,
  }) {
    return WorkWindow(
      weekdayStart: _timeOfDayFromMinutes(weekdayStart),
      weekdayEnd: _timeOfDayFromMinutes(weekdayEnd),
      weekendStart: _timeOfDayFromMinutes(weekendStart),
      weekendEnd: _timeOfDayFromMinutes(weekendEnd),
    );
  }
  final TimeOfDay weekdayStart;
  final TimeOfDay weekdayEnd;
  final TimeOfDay weekendStart;
  final TimeOfDay weekendEnd;
  bool isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }
  DateTime startFor(DateTime day) {
    final timeOfDay = isWeekend(day) ? weekendStart : weekdayStart;
    return DateTime(
      day.year,
      day.month,
      day.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
  DateTime endFor(DateTime day) {
    final timeOfDay = isWeekend(day) ? weekendEnd : weekdayEnd;
    return DateTime(
      day.year,
      day.month,
      day.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
  Duration durationFor(DateTime day) => endFor(day).difference(startFor(day));
  static int minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;
  static TimeOfDay _timeOfDayFromMinutes(int minutes) {
    final normalized = minutes.clamp(0, 24 * 60 - 1);
    return TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
  }
}

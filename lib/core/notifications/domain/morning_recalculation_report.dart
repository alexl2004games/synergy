import '../../database/app_database.dart';
class MorningRecalculationReport {
  const MorningRecalculationReport({
    required this.day,
    required this.rescheduledTasks,
    required this.dayKeptTasks,
    required this.dayOverflowTasks,
    required this.workWindowMinutes,
  });
  final DateTime day;
  final List<Task> rescheduledTasks;
  final List<Task> dayKeptTasks;
  final List<Task> dayOverflowTasks;
  final int workWindowMinutes;
  int get rescheduledCount => rescheduledTasks.length;
  int get keptCount => dayKeptTasks.length;
  int get overflowCount => dayOverflowTasks.length;
}

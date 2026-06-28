import 'dart:math' as math;
import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
class PriorityCalculator {
  double calculate(Task task, DateTime now) {
    final userPriorityValue = switch (task.priority) {
      TaskPriority.low => 0.3,
      TaskPriority.medium => 0.6,
      TaskPriority.high => 1.0,
    };
    final urgency = task.deadlineAt != null
        ? 1.0 /
            (math.max(
                  0,
                  DateTime.fromMillisecondsSinceEpoch(task.deadlineAt!)
                      .difference(now)
                      .inDays,
                ) +
                1)
        : 0.0;
    final sizeFactor = math.min(task.estMin / 60.0, 2.0) * 0.1;
    final daysOverdue = task.deadlineAt != null &&
            DateTime.fromMillisecondsSinceEpoch(task.deadlineAt!).isBefore(now)
        ? now
                .difference(
                  DateTime.fromMillisecondsSinceEpoch(task.deadlineAt!),
                )
                .inHours /
            24.0
        : 0.0;
    final overdueFactor = math.min(daysOverdue * 0.2, 1.0);
    return 0.4 * userPriorityValue +
        0.3 * urgency +
        0.1 * sizeFactor +
        0.2 * overdueFactor;
  }
  static double score(Task task, DateTime now) =>
      PriorityCalculator().calculate(task, now);
}
class EffectivePriorityCalculator {
  static double score(Task task, DateTime now) =>
      PriorityCalculator().calculate(task, now);
}

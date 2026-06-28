import 'package:drift/drift.dart' as drift;
import '../../database/app_database.dart' as app_db;
import '../../database/tables.dart' as db;
class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.notes,
    required this.startAt,
    required this.endAt,
    required this.deadlineAt,
    required this.estMin,
    required this.priority,
    required this.tags,
    required this.confidence,
  });
  final String title;
  final String notes;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? deadlineAt;
  final int estMin;
  final db.TaskPriority priority;
  final List<String> tags;
  final double confidence;
  app_db.TasksCompanion toCompanion() {
    return app_db.TasksCompanion(
      title: drift.Value(title),
      notes: drift.Value(notes),
      startAt: drift.Value(startAt?.millisecondsSinceEpoch),
      endAt: drift.Value(endAt?.millisecondsSinceEpoch),
      deadlineAt: drift.Value(deadlineAt?.millisecondsSinceEpoch),
      estMin: drift.Value(estMin),
      priority: drift.Value(priority),
      aiConfidence: drift.Value(confidence),
      isAllDay: drift.Value(startAt == null && endAt == null),
    );
  }
}

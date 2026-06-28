import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import 'recurrence_engine.dart';
final recurrenceEngineProvider = Provider<RecurrenceEngine>((ref) {
  final db = ref.watch(databaseProvider);
  return RecurrenceEngine(tasksDao: db.tasksDao);
});

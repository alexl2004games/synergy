// Temporarily disabled by user
// ignore_for_file: unused_field, unused_element
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:logging/logging.dart';
import '../../../core/database/app_database.dart' as app_db;
import '../../tasks/domain/task.dart' as task_domain;
class AICommandResult {
  const AICommandResult({
    required this.success,
    required this.message,
    this.executedCommands = const [],
  });
  final bool success;
  final String message;
  final List<String> executedCommands;
}
final aiCommandControllerProvider =
    StateNotifierProvider<AICommandController, AsyncValue<AICommandResult?>>(
        (ref) {
  return AICommandController(ref);
});
class AICommandController extends StateNotifier<AsyncValue<AICommandResult?>> {
  AICommandController(this._ref) : super(const AsyncData(null));
  final Ref _ref;
  final Logger _logger = Logger('AICommandController');
  Future<AICommandResult> execute(String text) async {
    state = const AsyncLoading();
    const result = AICommandResult(
      success: false,
      message: 'Многозадачный инференс временно отключён',
    );
    state = const AsyncData(result);
    return result;
  }
  app_db.Task? _findMatchingTask(
    List<app_db.Task> allTasks,
    String? targetTitle,
  ) {
    if (targetTitle == null || targetTitle.trim().isEmpty) return null;
    final query = targetTitle.trim().toLowerCase();
    for (final task in allTasks) {
      if (task.title.trim().toLowerCase() == query) {
        return task;
      }
    }
    for (final task in allTasks) {
      if (task.title.toLowerCase().contains(query)) {
        return task;
      }
    }
    for (final task in allTasks) {
      if (query.contains(task.title.toLowerCase())) {
        return task;
      }
    }
    return null;
  }
  task_domain.TaskPriority _mapPriority(String? prioStr) {
    if (prioStr == null) return task_domain.TaskPriority.medium;
    switch (prioStr.toLowerCase()) {
      case 'low':
        return task_domain.TaskPriority.low;
      case 'high':
        return task_domain.TaskPriority.high;
      default:
        return task_domain.TaskPriority.medium;
    }
  }
  String _cleanUserText(String text) {
    var cleaned = text.trim();
    cleaned = cleaned.replaceFirst(RegExp(r'^[зЗ]апрос:\s*'), '').trim();
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    } else if (cleaned.startsWith('«') && cleaned.endsWith('»')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    }
    return cleaned;
  }
}

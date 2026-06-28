import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/drift_task_repository.dart';
import '../../domain/task.dart' as domain;
class SpaceGroup {
  const SpaceGroup({
    required this.tag,
    required this.tasks,
  });
  final String tag;
  final List<domain.Task> tasks;
}
final spacesProvider = StreamProvider<List<SpaceGroup>>((ref) {
  final db = ref.watch(databaseProvider);
  final tasksStream = db.tasksDao.watchAllTasks();
  final tagsStream = db.taskTagsDao.watchAllTags();
  return Rx.combineLatest2(tasksStream, tagsStream, (tasksList, tagsList) {
    final domainTasks = tasksList.map((t) => t.toDomain()).toList();
    final grouped = <String, List<domain.Task>>{};
    final tagsByTaskId = <String, List<String>>{};
    for (final tagRow in tagsList) {
      tagsByTaskId
          .putIfAbsent(tagRow.taskId, () => [])
          .add(tagRow.tagName.trim());
    }
    final uniqueTasks = <domain.Task>[];
    final seenOriginalIds = <String>{};
    for (final task in domainTasks) {
      final key = task.parentTaskId ?? task.id;
      if (!seenOriginalIds.contains(key)) {
        seenOriginalIds.add(key);
        uniqueTasks.add(task);
      }
    }
    for (final task in uniqueTasks) {
      final tags = tagsByTaskId[task.id] ?? (task.parentTaskId != null ? tagsByTaskId[task.parentTaskId!] : null);
      if (tags != null && tags.isNotEmpty) {
        grouped.putIfAbsent(tags.first, () => []).add(task);
      } else {
        grouped.putIfAbsent('Без тега', () => []).add(task);
      }
    }
    return grouped.entries
        .map((e) => SpaceGroup(tag: e.key, tasks: e.value))
        .toList()
      ..sort((a, b) => a.tag.compareTo(b.tag));
  });
});

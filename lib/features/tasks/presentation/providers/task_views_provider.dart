import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/drift_task_repository.dart';
import 'tasks_provider.dart';
import '../../domain/task.dart';
import '../../application/task_repository_provider.dart'
    show taskRepositoryProvider;
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(tasksDaoProvider).watchAllTasks().map(
        (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
      );
});
final upcomingTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(tasksDaoProvider).watchUpcomingTasks().map(
        (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
      );
});
// ignore: specify_nonobvious_property_types
final tasksByDayProvider = StreamProvider.family<List<Task>, DateTime>(
  (ref, day) {
    return ref.watch(taskRepositoryProvider).watchByDay(day);
  },
);

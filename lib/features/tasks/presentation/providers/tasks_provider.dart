import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/database/daos/tasks_dao.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../checkin/application/check_in_repository_provider.dart';
import '../../application/task_repository_provider.dart';
import '../../domain/task.dart';
import '../../domain/task_checklist_item.dart';
import '../../domain/task_tag.dart';
final Provider<TasksDao> tasksDaoProvider = Provider<TasksDao>((ref) {
  return ref.watch(databaseProvider).tasksDao;
});
final StreamProvider<List<Task>> inboxTasksProvider =
    StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchInbox();
});
final StreamProvider<List<Task>> todayTasksProvider =
    StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchToday();
});
final taskByIdProvider = FutureProvider.family<Task?, String>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).getById(taskId);
});
final checklistByTaskIdProvider =
    StreamProvider.family<List<TaskChecklistItem>, String>((ref, taskId) {
  return ref.watch(checklistRepositoryProvider).watchByTaskId(taskId);
});
// ignore: specify_nonobvious_property_types
final taskTagsByTaskIdProvider =
    FutureProvider.family<List<TaskTag>, String>((ref, taskId) {
  return ref.watch(taskTagRepositoryProvider).getByTaskId(taskId);
});
final StreamProvider<bool> todayCheckInDoneProvider =
    StreamProvider<bool>((ref) {
  return ref.watch(checkInRepositoryProvider).watchAll().map((checkins) {
    final now = DateTime.now();
    return checkins.any(
      (checkin) =>
          checkin.date.year == now.year &&
          checkin.date.month == now.month &&
          checkin.date.day == now.day,
    );
  });
});
final confettiProvider = StateNotifierProvider<ConfettiNotifier, bool>((ref) {
  return ConfettiNotifier();
});
class ConfettiNotifier extends StateNotifier<bool> {
  ConfettiNotifier() : super(false);
  void play() {
    state = true;
    Future.delayed(const Duration(seconds: 4), () {
      state = false;
    });
  }
}

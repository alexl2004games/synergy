import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/checkin/application/check_in_repository_provider.dart';
import '../../providers/database_provider.dart';
import '../../router/app_router.dart';
import '../infrastructure/flutter_local_notifications_service.dart';
import 'app_bootstrap_service.dart';
import 'notification_service.dart';
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = FlutterLocalNotificationsService(
    tasksDao: db.tasksDao,
    settingsDao: db.settingsDao,
    onTap: (response) async {
      final payload = response.payload;
      if (payload == null || payload.isEmpty) {
        return;
      }
      if (payload == 'checkin') {
        final hasTodayCheckin = await ref
            .read(
              checkInRepositoryProvider,
            )
            .getByDate(DateTime.now());
        if (hasTodayCheckin != null) {
          return;
        }
        unawaited(ref.read(routerProvider).push('/checkin'));
        return;
      }
      if (payload == 'weekly_digest') {
        ref.read(routerProvider).go('/upcoming');
        return;
      }
      if (payload.startsWith('{')) {
        final taskId = _extractTaskId(payload);
        if (taskId != null) {
          ref.read(routerProvider).go('/task/$taskId');
        }
      }
    },
  );
  ref.onDispose(service.dispose);
  return service;
});
final appBootstrapServiceProvider = Provider<AppBootstrapService>((ref) {
  final db = ref.watch(databaseProvider);
  return AppBootstrapService(
    notificationService: ref.watch(notificationServiceProvider),
    tasksDao: db.tasksDao,
    settingsDao: db.settingsDao,
    aiProfileDao: db.aiProfileDao,
  );
});
String? _extractTaskId(String payload) {
  try {
    final decoded = payload.contains('taskId') ? payload : null;
    if (decoded == null) {
      return null;
    }
    final match = RegExp(r'"taskId"\s*:\s*"([^"]+)"').firstMatch(payload);
    return match?.group(1);
  } on Object {
    return null;
  }
}

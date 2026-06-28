import 'dart:async';
import '../../database/app_database.dart' as app_db;
import '../../../features/tasks/domain/task.dart';
import '../domain/notification_preferences.dart';
abstract class NotificationService {
  Future<void> initialize();
  Future<void> init() => initialize();
  Future<void> requestPermission();
  Future<void> requestPermissions() => requestPermission();
  Future<void> scheduleTaskReminder(Task task, int minutesBefore);
  Future<void> cancelTaskReminder(String taskId);
  Future<void> scheduleCheckInReminder();
  Future<void> scheduleWeeklyDigest();
  Future<void> syncRecurringNotifications(NotificationPreferences preferences);
  Future<void> syncTaskReminders(List<app_db.TaskReminder> reminders);
  Future<void> cancelAll();
  Future<void> dispose();
}

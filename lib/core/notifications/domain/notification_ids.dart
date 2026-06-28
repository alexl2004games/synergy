abstract final class NotificationIds {
  static const String checkinReminder = 'checkin_reminder';
  static const String weeklyDigest = 'weekly_digest';
  static const String taskReminderPrefix = 'task_reminder_';
  static String taskReminder(String taskId) => '$taskReminderPrefix$taskId';
  static int stableIntId(String value) => value.hashCode & 0x7fffffff;
}

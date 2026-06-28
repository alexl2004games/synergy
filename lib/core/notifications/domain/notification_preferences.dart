class NotificationPreferences {
  const NotificationPreferences({
    this.taskReminderMinutesBefore = 15,
    this.checkinReminderHour = 21,
    this.checkinReminderMinute = 0,
    this.morningDigestWeekday = DateTime.monday,
    this.morningDigestHour = 8,
    this.morningDigestMinute = 0,
    this.notificationsEnabled = true,
  });
  final int taskReminderMinutesBefore;
  final int checkinReminderHour;
  final int checkinReminderMinute;
  final int morningDigestWeekday;
  final int morningDigestHour;
  final int morningDigestMinute;
  final bool notificationsEnabled;
}

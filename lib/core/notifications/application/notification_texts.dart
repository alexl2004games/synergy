import 'dart:io';
import '../../localization/app_localizations_en.dart';
import '../../localization/app_localizations_ru.dart';
class NotificationTexts {
  NotificationTexts.en()
      : taskReminderTitle = AppLocalizationsEn().taskReminderTitle,
        taskReminderBody = AppLocalizationsEn().taskReminderBody,
        checkinReminderTitle = AppLocalizationsEn().checkinReminderTitle,
        checkinReminderBody = AppLocalizationsEn().checkinReminderBody,
        morningDigestTitle = AppLocalizationsEn().morningDigestTitle,
        morningDigestBody = AppLocalizationsEn().morningDigestBody;
  NotificationTexts.ru()
      : taskReminderTitle = AppLocalizationsRu().taskReminderTitle,
        taskReminderBody = AppLocalizationsRu().taskReminderBody,
        checkinReminderTitle = AppLocalizationsRu().checkinReminderTitle,
        checkinReminderBody = AppLocalizationsRu().checkinReminderBody,
        morningDigestTitle = AppLocalizationsRu().morningDigestTitle,
        morningDigestBody = AppLocalizationsRu().morningDigestBody;
  factory NotificationTexts.current() {
    final localeName = Platform.localeName.toLowerCase();
    if (localeName.startsWith('ru')) {
      return NotificationTexts.ru();
    }
    return NotificationTexts.en();
  }
  final String taskReminderTitle;
  final String taskReminderBody;
  final String checkinReminderTitle;
  final String checkinReminderBody;
  final String morningDigestTitle;
  final String morningDigestBody;
  String weeklyDigestBody(int deadlineCount, int tasksCount) {
    final localeName = Platform.localeName.toLowerCase();
    if (localeName.startsWith('ru')) {
      return AppLocalizationsRu().weeklyDigestBody(deadlineCount, tasksCount);
    }
    return AppLocalizationsEn().weeklyDigestBody(deadlineCount, tasksCount);
  }
}

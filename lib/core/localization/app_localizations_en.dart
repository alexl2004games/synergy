// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Synergy';

  @override
  String get today => 'Today';

  @override
  String get inbox => 'Inbox';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get calendar => 'Calendar';

  @override
  String get analytics => 'Analytics';

  @override
  String get settings => 'Settings';

  @override
  String get todayTab => 'Today';

  @override
  String get inboxTab => 'Inbox';

  @override
  String get upcomingTab => 'Upcoming';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get analyticsTab => 'Analytics';

  @override
  String get settingsTab => 'Settings';

  @override
  String get lockScreenTitle => 'Enter PIN';

  @override
  String get onboardingTitle => 'Welcome to Synergy';

  @override
  String get onboardingSubtitle => 'Set up your privacy settings to begin.';

  @override
  String get onboarding_page1_title => 'Plan your day';

  @override
  String get onboarding_page1_body =>
      'Organize tasks, check-ins and reminders in one place.';

  @override
  String get onboarding_page2_title => 'Track progress';

  @override
  String get onboarding_page2_body =>
      'Daily check-ins help you find trends and improve routines.';

  @override
  String get onboarding_page3_title => 'Secure your data';

  @override
  String get onboarding_page3_body =>
      'Protect the app with a PIN and enable Face ID / Touch ID.';

  @override
  String get auth_enter_pin => 'Enter your PIN';

  @override
  String get auth_confirm_pin => 'Confirm your PIN';

  @override
  String get auth_pin_mismatch => 'PINs do not match. Try again.';

  @override
  String get auth_pin_setup_title => 'Set a secure PIN';

  @override
  String get auth_done => 'Done';

  @override
  String get auth_biometrics_opt_in_title => 'Enable biometrics?';

  @override
  String get auth_biometrics_opt_in_message =>
      'Use Face ID / Touch ID to quickly unlock the app.';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get learn_more => 'Learn more';

  @override
  String get next => 'Continue';

  @override
  String get finish => 'Finish';

  @override
  String get auth_setup_pin => 'Set up PIN';

  @override
  String get auth_setup_pin_description =>
      'Protect the app with a numeric PIN.';

  @override
  String get setPinButton => 'Set PIN';

  @override
  String get skipButton => 'Skip';

  @override
  String get enableFaceId => 'Enable Face ID / Touch ID';

  @override
  String get pinSetSuccess => 'PIN set successfully!';

  @override
  String get unlockWithBiometrics => 'Unlock with biometrics';

  @override
  String get invalidPin => 'Invalid PIN. Try again.';

  @override
  String get pinMustBeFourDigits => 'PIN must be at least 4 digits';

  @override
  String get checkinTitle => 'How was your day?';

  @override
  String get checkinMood => 'Mood';

  @override
  String get checkinProductivity => 'Productivity';

  @override
  String get checkinEnergy => 'Energy';

  @override
  String get checkinEnergyLowLabel => 'No energy';

  @override
  String get checkinEnergyHighLabel => 'Full of energy';

  @override
  String get checkinMoodLowEmoji => '😞';

  @override
  String get checkinMoodHighEmoji => '🙂';

  @override
  String get checkinProductivityLowLabel => 'Didn\'t work out';

  @override
  String get checkinProductivityHighLabel => 'Very productive';

  @override
  String get checkinNotes => 'Notes';

  @override
  String get checkinSave => 'Save';

  @override
  String get checkinAlreadyDone => 'You have already checked in today!';

  @override
  String get newTaskWhatNeedsToBeDone => 'What needs to be done?';

  @override
  String get newTaskNotes => 'Notes';

  @override
  String get newTaskEditTitle => 'Edit task';

  @override
  String get newTaskCreateButton => 'Create';

  @override
  String get taskNotesSectionTitle => 'Notes';

  @override
  String get taskChecklistSectionTitle => 'Checklist';

  @override
  String get taskChecklistAddLabel => 'Add checklist item';

  @override
  String get taskChecklistAddButton => 'Add item';

  @override
  String get taskChecklistItemLabel => 'Checklist item';

  @override
  String get taskChecklistEmptyBody => 'No checklist items yet.';

  @override
  String get taskPinnedLabel => 'Pin task';

  @override
  String get taskDetailsTitle => 'Task';

  @override
  String get taskDetailsNotFound => 'Task not found';

  @override
  String get taskDetailsTitleLabel => 'Title';

  @override
  String get taskDetailsNotesLabel => 'Notes';

  @override
  String get taskDetailsSaveButton => 'Save changes';

  @override
  String get taskDetailsSaved => 'Task saved';

  @override
  String get aiProcessingTitle => 'Synergy is thinking';

  @override
  String get aiProcessingSubtitle => 'AI is structuring your task…';

  @override
  String get voiceMicTooltip => 'Hold to record';

  @override
  String get voicePermissionTitle => 'Microphone access needed';

  @override
  String get voicePermissionBody =>
      'Please allow microphone access in Settings.';

  @override
  String get openSettingsButton => 'Open settings';

  @override
  String get voiceRecordingHint => 'Recording...';

  @override
  String get voiceTranscribingHint => 'Transcribing...';

  @override
  String get llmFallbackTaskCreated =>
      'Could not parse. Task created from text title.';

  @override
  String get taskConfirmTitle => 'Review task';

  @override
  String get taskConfirmNameLabel => 'Name';

  @override
  String get taskConfirmNotesLabel => 'Notes';

  @override
  String get taskConfirmEstimationLabel => 'Estimate, min';

  @override
  String get taskEstimatedDurationLabel => 'Duration';

  @override
  String taskDurationMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String get taskConfirmPriorityLabel => 'Priority';

  @override
  String get taskConfirmSaveButton => 'Save';

  @override
  String get taskPriorityLowLabel => 'Low';

  @override
  String get taskPriorityMediumLabel => 'Medium';

  @override
  String get taskPriorityHighLabel => 'High';

  @override
  String get taskConflictTitle => 'Time conflict';

  @override
  String get taskConflictBody =>
      'You already have a pinned task at this time. Save anyway?';

  @override
  String get taskConflictSaveAnywaysButton => 'Save anyway';

  @override
  String get recordingHint => 'Listening...';

  @override
  String get transcribingHint => 'Transcribing...';

  @override
  String get voiceInputHint => 'Say or type a task...';

  @override
  String get voiceSend => 'Send';

  @override
  String get taskReminderTitle => 'Task reminder';

  @override
  String get taskReminderBody => 'Your task is due soon.';

  @override
  String get checkinReminderTitle => 'Check-in reminder';

  @override
  String get checkinReminderBody => 'Don\'t forget to check in today.';

  @override
  String get morningDigestTitle => 'Morning digest';

  @override
  String get morningDigestBody => 'Here is your plan for today.';

  @override
  String get todayScheduledGroupTitle => 'Scheduled for a time';

  @override
  String get todayAllDayGroupTitle => 'For today';

  @override
  String get todayEmptyTitle => 'Free day';

  @override
  String get todayEmptyBody => 'No tasks for today.';

  @override
  String get inboxEmptyTitle => 'Inbox empty';

  @override
  String get inboxEmptyBody =>
      'Tasks without dates or quick notes will appear here.';

  @override
  String get inboxDeadlineSectionTitle => 'With deadline';

  @override
  String get inboxNoDateSectionTitle => 'No date';

  @override
  String get taskAllDayLabel => 'All day';

  @override
  String get taskConfidenceWarningTooltip => 'Low AI confidence';

  @override
  String get todayCheckinTooltip => 'Open check-in';

  @override
  String get taskDeletedSnack => 'Task deleted';

  @override
  String get undoButton => 'Undo';

  @override
  String get newTaskSheetTitle => 'New task';

  @override
  String get newTaskSheetBody => 'Placeholder for the next stage.';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search tasks, dates, notes and checklists';

  @override
  String get searchEmptyTitle => 'Start typing a query';

  @override
  String get searchEmptyBody =>
      'You can search by title, notes, checklists, tags and dates.';

  @override
  String get searchNoResultsTitle => 'Nothing found';

  @override
  String get searchNoResultsBody => 'Try a different word or date.';

  @override
  String get searchRecentTitle => 'Recent tasks';

  @override
  String get searchResultsTitle => 'Found';

  @override
  String get searchClearButton => 'Clear';

  @override
  String get closeButton => 'Close';

  @override
  String get upcomingEmptyTitle => 'No upcoming tasks';

  @override
  String get upcomingEmptyBody => 'Tasks with dates will appear here.';

  @override
  String get calendarEmptyTitle => 'Nothing on this day';

  @override
  String get calendarEmptyBody =>
      'Pick a different date to see scheduled tasks.';

  @override
  String get analyticsEmptyTitle => 'Not enough check-ins yet';

  @override
  String get analyticsEmptyBody => 'Complete a few check-ins to unlock trends.';

  @override
  String get analyticsNoData => 'No data yet';

  @override
  String get analyticsMoodProductivityTitle => 'Mood and productivity';

  @override
  String get analyticsPlanningAccuracyTitle => 'Planning accuracy';

  @override
  String get analyticsPlanningAccuracyBody =>
      'The closer the dots are to the diagonal, the more accurate the plan.';

  @override
  String get analyticsStreakTitle => 'Streak';

  @override
  String get analyticsStreakSuffix => 'days in a row';

  @override
  String get analyticsStreakBody => 'you complete at least one task every day';

  @override
  String get analyticsAverageMood => 'Average mood';

  @override
  String get analyticsAverageProductivity => 'Average productivity';

  @override
  String get analyticsRecentCheckins => 'Recent check-ins';

  @override
  String get backupSectionTitle => 'iCloud backup';

  @override
  String get backupSectionBody =>
      'Backups are stored in iCloud Drive and synced across devices.';

  @override
  String get backupAutoBackupTitle => 'Auto backup';

  @override
  String get backupAutoBackupBody =>
      'Create a backup once a day when the app starts.';

  @override
  String get backupSaveDialogTitle => 'Save backup file';

  @override
  String get backupCreateButton => 'Create backup now';

  @override
  String get backupImportButton => 'Import backup';

  @override
  String get backupLastBackupLabel => 'Last backup';

  @override
  String get backupNoBackupYet => 'No backups yet';

  @override
  String get backupRestoreDialogTitle => 'Restore a newer backup?';

  @override
  String get backupRestoreDialogBody =>
      'A more recent backup is available in iCloud Drive.';

  @override
  String get backupRestoreNowButton => 'Restore';

  @override
  String get backupRestoreLaterButton => 'Later';

  @override
  String get backupExportSuccess => 'Backup created successfully.';

  @override
  String get backupImportSuccess => 'Backup imported successfully.';

  @override
  String get backupError => 'Backup failed.';

  @override
  String get backupNoFileSelected => 'No backup file selected.';

  @override
  String get backupImportConfirmTitle => 'Import backup?';

  @override
  String get backupImportConfirmBody =>
      'Current data will be replaced by the selected backup.';

  @override
  String get backupImportConfirmButton => 'Import';

  @override
  String get themeSectionTitle => 'Appearance';

  @override
  String get themeOptionLight => 'Light';

  @override
  String get themeOptionDark => 'Dark';

  @override
  String get themeOptionSystem => 'System';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageOptionEn => 'English';

  @override
  String get languageOptionRu => 'Русский';

  @override
  String get languageChangedToEn => 'Language: English';

  @override
  String get workingHoursSectionTitle => 'Working hours';

  @override
  String get workingHoursStart => 'Start';

  @override
  String get workingHoursEnd => 'End';

  @override
  String get workingHoursDescription => 'Time window for task scheduling';

  @override
  String get notificationsSectionTitle => 'Notifications';

  @override
  String get notificationsEnabled => 'Enable notifications';

  @override
  String get notificationsDisabled => 'Notifications are disabled';

  @override
  String get taskReminderMinutesBeforeLabel => 'Task reminder lead time';

  @override
  String get checkinReminderTimeLabel => 'Check-in reminder time';

  @override
  String get morningDigestEnabled => 'Morning digest';

  @override
  String get checkinReminderEnabled => 'Check-in reminder';

  @override
  String get biometrySectionTitle => 'Security';

  @override
  String get biometryEnabled => 'Use biometrics';

  @override
  String get pinSectionTitle => 'PIN protection';

  @override
  String get changePinButton => 'Change PIN';

  @override
  String get aboutSectionTitle => 'About';

  @override
  String appVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get appDeveloper => 'alexl2004games';

  @override
  String get appPrivacy => 'Privacy policy';

  @override
  String get appTerms => 'Terms of use';

  @override
  String get spacesTab => 'Spaces';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get recurrenceTitle => 'Repeat';

  @override
  String get recurrenceNone => 'No repeat';

  @override
  String get recurrenceDaily => 'Every day';

  @override
  String get recurrenceWeekdays => 'Every weekday';

  @override
  String get recurrenceWeekly => 'Every week';

  @override
  String get recurrenceMonthly => 'Every month';

  @override
  String get recurrenceYearly => 'Every year';

  @override
  String get deleteRecurrenceInstanceTitle => 'Delete task?';

  @override
  String get deleteRecurrenceInstanceBody =>
      'Delete only this task or all future ones?';

  @override
  String get deleteRecurrenceInstanceOnly => 'Only this task';

  @override
  String get deleteRecurrenceInstanceFuture => 'This and future';

  @override
  String get deleteRecurrenceAllButton => 'All';

  @override
  String get deleteButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get morningPlanTitle => 'Good morning! Here\'s your plan for today';

  @override
  String get morningOverdueTitle => 'Overdue tasks moved';

  @override
  String get morningTodayOverloadedTitle => 'Today is overloaded';

  @override
  String get morningTomorrowOverloadedTitle => 'Tomorrow is overloaded';

  @override
  String get morningNoSlotFound => 'No slot found';

  @override
  String get morningMinutes => 'min';

  @override
  String get morningAcceptAllButton => 'Accept all';

  @override
  String get morningCustomizeButton => 'Customize';

  @override
  String get morningCustomizeTitle => 'Customize your plan';

  @override
  String get morningApplyButton => 'Apply';

  @override
  String weeklyDigestBody(Object deadlineCount, Object tasksCount) {
    return 'This week you have $tasksCount tasks, $deadlineCount with deadlines';
  }

  @override
  String get appearanceSectionTitle => 'Appearance';

  @override
  String get scheduleSectionTitle => 'Schedule';

  @override
  String get scheduleDescription =>
      'Set work hours for different days of the week';

  @override
  String get workingHoursWeekdaysLabel => 'Weekdays';

  @override
  String get workingHoursWeekendsLabel => 'Weekends';

  @override
  String get resetToDefaultButton => 'Reset to default';

  @override
  String get securitySectionTitle => 'Security';

  @override
  String get pinEnabledLabel => 'Enable PIN protection';

  @override
  String get pinEnabledToolTip => 'Require PIN to unlock the app';

  @override
  String get autoLockTimeoutLabel => 'Auto-lock timeout';

  @override
  String get autoLockTimeout30s => '30 seconds';

  @override
  String get autoLockTimeout1m => '1 minute';

  @override
  String get autoLockTimeout5m => '5 minutes';

  @override
  String get taskRemindersLabel => 'Task reminders';

  @override
  String get minutesLabel => 'minutes';

  @override
  String get featureNotImplementedLabel => 'Feature not implemented';

  @override
  String get licensesButton => 'Licenses';

  @override
  String get openSourceProjectsLabel => 'Open source projects';

  @override
  String get logoutButton => 'Log out';

  @override
  String get taskCompleted => 'Completed';
}

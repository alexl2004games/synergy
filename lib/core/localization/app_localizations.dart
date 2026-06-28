import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Synergy'**
  String get appName;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @todayTab.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTab;

  /// No description provided for @inboxTab.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inboxTab;

  /// No description provided for @upcomingTab.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingTab;

  /// No description provided for @calendarTab.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTab;

  /// No description provided for @analyticsTab.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @lockScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get lockScreenTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Synergy'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your privacy settings to begin.'**
  String get onboardingSubtitle;

  /// No description provided for @onboarding_page1_title.
  ///
  /// In en, this message translates to:
  /// **'Plan your day'**
  String get onboarding_page1_title;

  /// No description provided for @onboarding_page1_body.
  ///
  /// In en, this message translates to:
  /// **'Organize tasks, check-ins and reminders in one place.'**
  String get onboarding_page1_body;

  /// No description provided for @onboarding_page2_title.
  ///
  /// In en, this message translates to:
  /// **'Track progress'**
  String get onboarding_page2_title;

  /// No description provided for @onboarding_page2_body.
  ///
  /// In en, this message translates to:
  /// **'Daily check-ins help you find trends and improve routines.'**
  String get onboarding_page2_body;

  /// No description provided for @onboarding_page3_title.
  ///
  /// In en, this message translates to:
  /// **'Secure your data'**
  String get onboarding_page3_title;

  /// No description provided for @onboarding_page3_body.
  ///
  /// In en, this message translates to:
  /// **'Protect the app with a PIN and enable Face ID / Touch ID.'**
  String get onboarding_page3_body;

  /// No description provided for @auth_enter_pin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get auth_enter_pin;

  /// No description provided for @auth_confirm_pin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get auth_confirm_pin;

  /// No description provided for @auth_pin_mismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get auth_pin_mismatch;

  /// No description provided for @auth_pin_setup_title.
  ///
  /// In en, this message translates to:
  /// **'Set a secure PIN'**
  String get auth_pin_setup_title;

  /// No description provided for @auth_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get auth_done;

  /// No description provided for @auth_biometrics_opt_in_title.
  ///
  /// In en, this message translates to:
  /// **'Enable biometrics?'**
  String get auth_biometrics_opt_in_title;

  /// No description provided for @auth_biometrics_opt_in_message.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID / Touch ID to quickly unlock the app.'**
  String get auth_biometrics_opt_in_message;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @learn_more.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learn_more;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @auth_setup_pin.
  ///
  /// In en, this message translates to:
  /// **'Set up PIN'**
  String get auth_setup_pin;

  /// No description provided for @auth_setup_pin_description.
  ///
  /// In en, this message translates to:
  /// **'Protect the app with a numeric PIN.'**
  String get auth_setup_pin_description;

  /// No description provided for @setPinButton.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPinButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @enableFaceId.
  ///
  /// In en, this message translates to:
  /// **'Enable Face ID / Touch ID'**
  String get enableFaceId;

  /// No description provided for @pinSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN set successfully!'**
  String get pinSetSuccess;

  /// No description provided for @unlockWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get unlockWithBiometrics;

  /// No description provided for @invalidPin.
  ///
  /// In en, this message translates to:
  /// **'Invalid PIN. Try again.'**
  String get invalidPin;

  /// No description provided for @pinMustBeFourDigits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits'**
  String get pinMustBeFourDigits;

  /// No description provided for @checkinTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your day?'**
  String get checkinTitle;

  /// No description provided for @checkinMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get checkinMood;

  /// No description provided for @checkinProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get checkinProductivity;

  /// No description provided for @checkinEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get checkinEnergy;

  /// No description provided for @checkinEnergyLowLabel.
  ///
  /// In en, this message translates to:
  /// **'No energy'**
  String get checkinEnergyLowLabel;

  /// No description provided for @checkinEnergyHighLabel.
  ///
  /// In en, this message translates to:
  /// **'Full of energy'**
  String get checkinEnergyHighLabel;

  /// No description provided for @checkinMoodLowEmoji.
  ///
  /// In en, this message translates to:
  /// **'😞'**
  String get checkinMoodLowEmoji;

  /// No description provided for @checkinMoodHighEmoji.
  ///
  /// In en, this message translates to:
  /// **'🙂'**
  String get checkinMoodHighEmoji;

  /// No description provided for @checkinProductivityLowLabel.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t work out'**
  String get checkinProductivityLowLabel;

  /// No description provided for @checkinProductivityHighLabel.
  ///
  /// In en, this message translates to:
  /// **'Very productive'**
  String get checkinProductivityHighLabel;

  /// No description provided for @checkinNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get checkinNotes;

  /// No description provided for @checkinSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get checkinSave;

  /// No description provided for @checkinAlreadyDone.
  ///
  /// In en, this message translates to:
  /// **'You have already checked in today!'**
  String get checkinAlreadyDone;

  /// No description provided for @newTaskWhatNeedsToBeDone.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get newTaskWhatNeedsToBeDone;

  /// No description provided for @newTaskNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get newTaskNotes;

  /// No description provided for @newTaskEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get newTaskEditTitle;

  /// No description provided for @newTaskCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get newTaskCreateButton;

  /// No description provided for @taskNotesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get taskNotesSectionTitle;

  /// No description provided for @taskChecklistSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get taskChecklistSectionTitle;

  /// No description provided for @taskChecklistAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Add checklist item'**
  String get taskChecklistAddLabel;

  /// No description provided for @taskChecklistAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get taskChecklistAddButton;

  /// No description provided for @taskChecklistItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Checklist item'**
  String get taskChecklistItemLabel;

  /// No description provided for @taskChecklistEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No checklist items yet.'**
  String get taskChecklistEmptyBody;

  /// No description provided for @taskPinnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Pin task'**
  String get taskPinnedLabel;

  /// No description provided for @taskDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskDetailsTitle;

  /// No description provided for @taskDetailsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskDetailsNotFound;

  /// No description provided for @taskDetailsTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskDetailsTitleLabel;

  /// No description provided for @taskDetailsNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get taskDetailsNotesLabel;

  /// No description provided for @taskDetailsSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get taskDetailsSaveButton;

  /// No description provided for @taskDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Task saved'**
  String get taskDetailsSaved;

  /// No description provided for @aiProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Synergy is thinking'**
  String get aiProcessingTitle;

  /// No description provided for @aiProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI is structuring your task…'**
  String get aiProcessingSubtitle;

  /// No description provided for @voiceMicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hold to record'**
  String get voiceMicTooltip;

  /// No description provided for @voicePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access needed'**
  String get voicePermissionTitle;

  /// No description provided for @voicePermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Please allow microphone access in Settings.'**
  String get voicePermissionBody;

  /// No description provided for @openSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsButton;

  /// No description provided for @voiceRecordingHint.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get voiceRecordingHint;

  /// No description provided for @voiceTranscribingHint.
  ///
  /// In en, this message translates to:
  /// **'Transcribing...'**
  String get voiceTranscribingHint;

  /// No description provided for @llmFallbackTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Could not parse. Task created from text title.'**
  String get llmFallbackTaskCreated;

  /// No description provided for @taskConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Review task'**
  String get taskConfirmTitle;

  /// No description provided for @taskConfirmNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get taskConfirmNameLabel;

  /// No description provided for @taskConfirmNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get taskConfirmNotesLabel;

  /// No description provided for @taskConfirmEstimationLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimate, min'**
  String get taskConfirmEstimationLabel;

  /// No description provided for @taskEstimatedDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get taskEstimatedDurationLabel;

  /// No description provided for @taskDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 min} other{{minutes} min}}'**
  String taskDurationMinutes(num minutes);

  /// No description provided for @taskConfirmPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskConfirmPriorityLabel;

  /// No description provided for @taskConfirmSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get taskConfirmSaveButton;

  /// No description provided for @taskPriorityLowLabel.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get taskPriorityLowLabel;

  /// No description provided for @taskPriorityMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get taskPriorityMediumLabel;

  /// No description provided for @taskPriorityHighLabel.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get taskPriorityHighLabel;

  /// No description provided for @taskConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Time conflict'**
  String get taskConflictTitle;

  /// No description provided for @taskConflictBody.
  ///
  /// In en, this message translates to:
  /// **'You already have a pinned task at this time. Save anyway?'**
  String get taskConflictBody;

  /// No description provided for @taskConflictSaveAnywaysButton.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get taskConflictSaveAnywaysButton;

  /// No description provided for @recordingHint.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get recordingHint;

  /// No description provided for @transcribingHint.
  ///
  /// In en, this message translates to:
  /// **'Transcribing...'**
  String get transcribingHint;

  /// No description provided for @voiceInputHint.
  ///
  /// In en, this message translates to:
  /// **'Say or type a task...'**
  String get voiceInputHint;

  /// No description provided for @voiceSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get voiceSend;

  /// No description provided for @taskReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Task reminder'**
  String get taskReminderTitle;

  /// No description provided for @taskReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Your task is due soon.'**
  String get taskReminderBody;

  /// No description provided for @checkinReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in reminder'**
  String get checkinReminderTitle;

  /// No description provided for @checkinReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to check in today.'**
  String get checkinReminderBody;

  /// No description provided for @morningDigestTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning digest'**
  String get morningDigestTitle;

  /// No description provided for @morningDigestBody.
  ///
  /// In en, this message translates to:
  /// **'Here is your plan for today.'**
  String get morningDigestBody;

  /// No description provided for @todayScheduledGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for a time'**
  String get todayScheduledGroupTitle;

  /// No description provided for @todayAllDayGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'For today'**
  String get todayAllDayGroupTitle;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Free day'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No tasks for today.'**
  String get todayEmptyBody;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox empty'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks without dates or quick notes will appear here.'**
  String get inboxEmptyBody;

  /// No description provided for @inboxDeadlineSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'With deadline'**
  String get inboxDeadlineSectionTitle;

  /// No description provided for @inboxNoDateSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get inboxNoDateSectionTitle;

  /// No description provided for @taskAllDayLabel.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get taskAllDayLabel;

  /// No description provided for @taskConfidenceWarningTooltip.
  ///
  /// In en, this message translates to:
  /// **'Low AI confidence'**
  String get taskConfidenceWarningTooltip;

  /// No description provided for @todayCheckinTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open check-in'**
  String get todayCheckinTooltip;

  /// No description provided for @taskDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeletedSnack;

  /// No description provided for @undoButton.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoButton;

  /// No description provided for @newTaskSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTaskSheetTitle;

  /// No description provided for @newTaskSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Placeholder for the next stage.'**
  String get newTaskSheetBody;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks, dates, notes and checklists'**
  String get searchHint;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start typing a query'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'You can search by title, notes, checklists, tags and dates.'**
  String get searchEmptyBody;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different word or date.'**
  String get searchNoResultsBody;

  /// No description provided for @searchRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent tasks'**
  String get searchRecentTitle;

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get searchResultsTitle;

  /// No description provided for @searchClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @upcomingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming tasks'**
  String get upcomingEmptyTitle;

  /// No description provided for @upcomingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks with dates will appear here.'**
  String get upcomingEmptyBody;

  /// No description provided for @calendarEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this day'**
  String get calendarEmptyTitle;

  /// No description provided for @calendarEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a different date to see scheduled tasks.'**
  String get calendarEmptyBody;

  /// No description provided for @analyticsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough check-ins yet'**
  String get analyticsEmptyTitle;

  /// No description provided for @analyticsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a few check-ins to unlock trends.'**
  String get analyticsEmptyBody;

  /// No description provided for @analyticsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get analyticsNoData;

  /// No description provided for @analyticsMoodProductivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood and productivity'**
  String get analyticsMoodProductivityTitle;

  /// No description provided for @analyticsPlanningAccuracyTitle.
  ///
  /// In en, this message translates to:
  /// **'Planning accuracy'**
  String get analyticsPlanningAccuracyTitle;

  /// No description provided for @analyticsPlanningAccuracyBody.
  ///
  /// In en, this message translates to:
  /// **'The closer the dots are to the diagonal, the more accurate the plan.'**
  String get analyticsPlanningAccuracyBody;

  /// No description provided for @analyticsStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get analyticsStreakTitle;

  /// No description provided for @analyticsStreakSuffix.
  ///
  /// In en, this message translates to:
  /// **'days in a row'**
  String get analyticsStreakSuffix;

  /// No description provided for @analyticsStreakBody.
  ///
  /// In en, this message translates to:
  /// **'you complete at least one task every day'**
  String get analyticsStreakBody;

  /// No description provided for @analyticsAverageMood.
  ///
  /// In en, this message translates to:
  /// **'Average mood'**
  String get analyticsAverageMood;

  /// No description provided for @analyticsAverageProductivity.
  ///
  /// In en, this message translates to:
  /// **'Average productivity'**
  String get analyticsAverageProductivity;

  /// No description provided for @analyticsRecentCheckins.
  ///
  /// In en, this message translates to:
  /// **'Recent check-ins'**
  String get analyticsRecentCheckins;

  /// No description provided for @backupSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'iCloud backup'**
  String get backupSectionTitle;

  /// No description provided for @backupSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Backups are stored in iCloud Drive and synced across devices.'**
  String get backupSectionBody;

  /// No description provided for @backupAutoBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto backup'**
  String get backupAutoBackupTitle;

  /// No description provided for @backupAutoBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Create a backup once a day when the app starts.'**
  String get backupAutoBackupBody;

  /// No description provided for @backupSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save backup file'**
  String get backupSaveDialogTitle;

  /// No description provided for @backupCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create backup now'**
  String get backupCreateButton;

  /// No description provided for @backupImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get backupImportButton;

  /// No description provided for @backupLastBackupLabel.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get backupLastBackupLabel;

  /// No description provided for @backupNoBackupYet.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get backupNoBackupYet;

  /// No description provided for @backupRestoreDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore a newer backup?'**
  String get backupRestoreDialogTitle;

  /// No description provided for @backupRestoreDialogBody.
  ///
  /// In en, this message translates to:
  /// **'A more recent backup is available in iCloud Drive.'**
  String get backupRestoreDialogBody;

  /// No description provided for @backupRestoreNowButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestoreNowButton;

  /// No description provided for @backupRestoreLaterButton.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get backupRestoreLaterButton;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully.'**
  String get backupExportSuccess;

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup imported successfully.'**
  String get backupImportSuccess;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Backup failed.'**
  String get backupError;

  /// No description provided for @backupNoFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No backup file selected.'**
  String get backupNoFileSelected;

  /// No description provided for @backupImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import backup?'**
  String get backupImportConfirmTitle;

  /// No description provided for @backupImportConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Current data will be replaced by the selected backup.'**
  String get backupImportConfirmBody;

  /// No description provided for @backupImportConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get backupImportConfirmButton;

  /// No description provided for @themeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeSectionTitle;

  /// No description provided for @themeOptionLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeOptionLight;

  /// No description provided for @themeOptionDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeOptionDark;

  /// No description provided for @themeOptionSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeOptionSystem;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// No description provided for @languageOptionEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageOptionEn;

  /// No description provided for @languageOptionRu.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageOptionRu;

  /// No description provided for @languageChangedToEn.
  ///
  /// In en, this message translates to:
  /// **'Language: English'**
  String get languageChangedToEn;

  /// No description provided for @workingHoursSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingHoursSectionTitle;

  /// No description provided for @workingHoursStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get workingHoursStart;

  /// No description provided for @workingHoursEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get workingHoursEnd;

  /// No description provided for @workingHoursDescription.
  ///
  /// In en, this message translates to:
  /// **'Time window for task scheduling'**
  String get workingHoursDescription;

  /// No description provided for @notificationsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSectionTitle;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled'**
  String get notificationsDisabled;

  /// No description provided for @taskReminderMinutesBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Task reminder lead time'**
  String get taskReminderMinutesBeforeLabel;

  /// No description provided for @checkinReminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-in reminder time'**
  String get checkinReminderTimeLabel;

  /// No description provided for @morningDigestEnabled.
  ///
  /// In en, this message translates to:
  /// **'Morning digest'**
  String get morningDigestEnabled;

  /// No description provided for @checkinReminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Check-in reminder'**
  String get checkinReminderEnabled;

  /// No description provided for @biometrySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get biometrySectionTitle;

  /// No description provided for @biometryEnabled.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get biometryEnabled;

  /// No description provided for @pinSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'PIN protection'**
  String get pinSectionTitle;

  /// No description provided for @changePinButton.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinButton;

  /// No description provided for @aboutSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSectionTitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(Object version);

  /// No description provided for @appDeveloper.
  ///
  /// In en, this message translates to:
  /// **'alexl2004games'**
  String get appDeveloper;

  /// No description provided for @appPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get appPrivacy;

  /// No description provided for @appTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get appTerms;

  /// No description provided for @spacesTab.
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get spacesTab;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @recurrenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get recurrenceTitle;

  /// No description provided for @recurrenceNone.
  ///
  /// In en, this message translates to:
  /// **'No repeat'**
  String get recurrenceNone;

  /// No description provided for @recurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Every weekday'**
  String get recurrenceWeekdays;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get recurrenceMonthly;

  /// No description provided for @recurrenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get recurrenceYearly;

  /// No description provided for @deleteRecurrenceInstanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get deleteRecurrenceInstanceTitle;

  /// No description provided for @deleteRecurrenceInstanceBody.
  ///
  /// In en, this message translates to:
  /// **'Delete only this task or all future ones?'**
  String get deleteRecurrenceInstanceBody;

  /// No description provided for @deleteRecurrenceInstanceOnly.
  ///
  /// In en, this message translates to:
  /// **'Only this task'**
  String get deleteRecurrenceInstanceOnly;

  /// No description provided for @deleteRecurrenceInstanceFuture.
  ///
  /// In en, this message translates to:
  /// **'This and future'**
  String get deleteRecurrenceInstanceFuture;

  /// No description provided for @deleteRecurrenceAllButton.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get deleteRecurrenceAllButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @morningPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Good morning! Here\'s your plan for today'**
  String get morningPlanTitle;

  /// No description provided for @morningOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdue tasks moved'**
  String get morningOverdueTitle;

  /// No description provided for @morningTodayOverloadedTitle.
  ///
  /// In en, this message translates to:
  /// **'Today is overloaded'**
  String get morningTodayOverloadedTitle;

  /// No description provided for @morningTomorrowOverloadedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow is overloaded'**
  String get morningTomorrowOverloadedTitle;

  /// No description provided for @morningNoSlotFound.
  ///
  /// In en, this message translates to:
  /// **'No slot found'**
  String get morningNoSlotFound;

  /// No description provided for @morningMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get morningMinutes;

  /// No description provided for @morningAcceptAllButton.
  ///
  /// In en, this message translates to:
  /// **'Accept all'**
  String get morningAcceptAllButton;

  /// No description provided for @morningCustomizeButton.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get morningCustomizeButton;

  /// No description provided for @morningCustomizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your plan'**
  String get morningCustomizeTitle;

  /// No description provided for @morningApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get morningApplyButton;

  /// No description provided for @weeklyDigestBody.
  ///
  /// In en, this message translates to:
  /// **'This week you have {tasksCount} tasks, {deadlineCount} with deadlines'**
  String weeklyDigestBody(Object deadlineCount, Object tasksCount);

  /// No description provided for @appearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// No description provided for @scheduleSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleSectionTitle;

  /// No description provided for @scheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Set work hours for different days of the week'**
  String get scheduleDescription;

  /// No description provided for @workingHoursWeekdaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get workingHoursWeekdaysLabel;

  /// No description provided for @workingHoursWeekendsLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get workingHoursWeekendsLabel;

  /// No description provided for @resetToDefaultButton.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefaultButton;

  /// No description provided for @securitySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySectionTitle;

  /// No description provided for @pinEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable PIN protection'**
  String get pinEnabledLabel;

  /// No description provided for @pinEnabledToolTip.
  ///
  /// In en, this message translates to:
  /// **'Require PIN to unlock the app'**
  String get pinEnabledToolTip;

  /// No description provided for @autoLockTimeoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock timeout'**
  String get autoLockTimeoutLabel;

  /// No description provided for @autoLockTimeout30s.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get autoLockTimeout30s;

  /// No description provided for @autoLockTimeout1m.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get autoLockTimeout1m;

  /// No description provided for @autoLockTimeout5m.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get autoLockTimeout5m;

  /// No description provided for @taskRemindersLabel.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get taskRemindersLabel;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesLabel;

  /// No description provided for @featureNotImplementedLabel.
  ///
  /// In en, this message translates to:
  /// **'Feature not implemented'**
  String get featureNotImplementedLabel;

  /// No description provided for @licensesButton.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licensesButton;

  /// No description provided for @openSourceProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Open source projects'**
  String get openSourceProjectsLabel;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutButton;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskCompleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

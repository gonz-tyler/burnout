import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('es'),
  ];

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'dashboard.'**
  String get dashboardTitle;

  /// No description provided for @workoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'workouts.'**
  String get workoutsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'profile.'**
  String get profileTitle;

  /// Profile page progress section title
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// Encouragement message on profile
  ///
  /// In en, this message translates to:
  /// **'Keep building greatness!'**
  String get keepProgressing;

  /// Total workouts stat label
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get totalWorkouts;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left on Streak'**
  String get daysLeft;

  /// Completed today stat label
  ///
  /// In en, this message translates to:
  /// **'Completed Due Today'**
  String get completedToday;

  /// Total completions stat label
  ///
  /// In en, this message translates to:
  /// **'Total Completions'**
  String get totalCompletions;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Settings description
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience and preferences'**
  String get customizeAppExperience;

  /// Support section title
  ///
  /// In en, this message translates to:
  /// **'Support the Creator'**
  String get supportTheCreator;

  /// Support section question
  ///
  /// In en, this message translates to:
  /// **'Enjoying the app?'**
  String get enjoyingTheApp;

  /// Support section description
  ///
  /// In en, this message translates to:
  /// **'Your support helps us continue improving and adding new features!'**
  String get supportHelpsImprove;

  /// Rate app button text
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// Buy coffee button text
  ///
  /// In en, this message translates to:
  /// **'Buy Coffee'**
  String get buyCoffee;

  /// Coming soon dialog title
  ///
  /// In en, this message translates to:
  /// **'Coming Soon!'**
  String get comingSoon;

  /// Coming soon dialog message
  ///
  /// In en, this message translates to:
  /// **'{feature} will be available in a future update.'**
  String featureAvailableInFuture(String feature);

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with '**
  String get madeWithLove;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Description for customizing app preferences
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience and preferences'**
  String get customizePreferences;

  /// Support section title
  ///
  /// In en, this message translates to:
  /// **'Support the Creator'**
  String get supportCreator;

  /// Support section question
  ///
  /// In en, this message translates to:
  /// **'Enjoying the app?'**
  String get enjoyingApp;

  /// Support section description
  ///
  /// In en, this message translates to:
  /// **'Your support helps us continue improving and adding new features!'**
  String get supportMessage;

  /// Button text for rating the app
  ///
  /// In en, this message translates to:
  /// **'App Store Rating'**
  String get appStoreRating;

  /// Title for support options
  ///
  /// In en, this message translates to:
  /// **'Support Options'**
  String get supportOptions;

  /// Short description of the app
  ///
  /// In en, this message translates to:
  /// **'Build a better body, one day at a time.'**
  String get appDescription;

  /// Language section header
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language selection title
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelection;

  /// Description for language selection
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app interface'**
  String get languageSelectionDescription;

  /// System default option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Description for following device language
  ///
  /// In en, this message translates to:
  /// **'Follow device language settings'**
  String get followDeviceLanguage;

  /// Description for English language option
  ///
  /// In en, this message translates to:
  /// **'Change the application language to English.'**
  String get englishLanguageDescription;

  /// Description for Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Cambiar el idioma de la aplicación a español.'**
  String get spanishLanguageDescription;

  /// No description provided for @frenchLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Changer la langue de l\'application en français.'**
  String get frenchLanguageDescription;

  /// Appearance section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme mode selection title
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// Description for theme mode selection
  ///
  /// In en, this message translates to:
  /// **'Choose between light, dark, or system theme'**
  String get themeModeDescription;

  /// Description for following device theme
  ///
  /// In en, this message translates to:
  /// **'Follow device theme settings'**
  String get followDeviceSettings;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Description for light theme
  ///
  /// In en, this message translates to:
  /// **'Use light theme colors'**
  String get lightModeDescription;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Description for dark theme
  ///
  /// In en, this message translates to:
  /// **'Use dark theme colors'**
  String get darkModeDescription;

  /// Color theme selection title
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// Description for color theme selection
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred color scheme'**
  String get colorThemeDescription;

  /// Quotes section header
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quotes;

  /// Show quotes toggle
  ///
  /// In en, this message translates to:
  /// **'Show Quotes'**
  String get showQuotes;

  /// Description for quotes feature
  ///
  /// In en, this message translates to:
  /// **'Display inspirational quotes throughout the app'**
  String get quotesDescription;

  /// Message when quotes are enabled
  ///
  /// In en, this message translates to:
  /// **'Quotes enabled'**
  String get quotesEnabled;

  /// Message when quotes are disabled
  ///
  /// In en, this message translates to:
  /// **'Quotes disabled'**
  String get quotesDisabled;

  /// Daily mood quiz section header and title
  ///
  /// In en, this message translates to:
  /// **'Daily Mood Quiz'**
  String get dailyMoodQuiz;

  /// Description for mood quiz feature
  ///
  /// In en, this message translates to:
  /// **'Track your daily mood and emotional well-being'**
  String get moodQuizDescription;

  /// Message when mood quiz is enabled
  ///
  /// In en, this message translates to:
  /// **'Daily mood quiz enabled'**
  String get moodQuizEnabled;

  /// Message when mood quiz is disabled
  ///
  /// In en, this message translates to:
  /// **'Daily mood quiz disabled'**
  String get moodQuizDisabled;

  /// Notifications section header
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Daily reminders setting
  ///
  /// In en, this message translates to:
  /// **'Daily Reminders'**
  String get dailyReminders;

  /// Description for daily reminders
  ///
  /// In en, this message translates to:
  /// **'Get reminded to check in with your habits daily'**
  String get dailyRemindersDescription;

  /// Streak notifications setting
  ///
  /// In en, this message translates to:
  /// **'Streak Notifications'**
  String get streakNotifications;

  /// Description for streak notifications
  ///
  /// In en, this message translates to:
  /// **'Get notified about your habit streaks and milestones'**
  String get streakNotificationsDescription;

  /// Quote of the day notification setting
  ///
  /// In en, this message translates to:
  /// **'Quote of the Day'**
  String get quoteOfTheDay;

  /// Description for quote of the day notifications
  ///
  /// In en, this message translates to:
  /// **'Receive daily inspirational quotes'**
  String get quoteOfTheDayDescription;

  /// Data and privacy section header
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataAndPrivacy;

  /// Export data option
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Description for export data feature
  ///
  /// In en, this message translates to:
  /// **'Export all your data to a backup file'**
  String get exportDataDescription;

  /// Import data option
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// Description for import data feature
  ///
  /// In en, this message translates to:
  /// **'Import data from a backup file'**
  String get importDataDescription;

  /// Clear all data option
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// Description for clear all data feature
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all your data'**
  String get clearAllDataDescription;

  /// Warning message for clearing all data
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your habits, progress, and settings will be permanently deleted.'**
  String get clearAllDataWarning;

  /// About section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Privacy policy option
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Description for privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get privacyPolicyDescription;

  /// Terms of service option
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Description for terms of service link
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get termsOfServiceDescription;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Error message when privacy policy cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open privacy policy'**
  String get couldNotOpenPrivacyPolicy;

  /// Error message when terms of service cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open terms of service'**
  String get couldNotOpenTermsOfService;

  /// Loading message while exporting data
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get exportingData;

  /// Error message when storage cannot be accessed
  ///
  /// In en, this message translates to:
  /// **'Could not access storage'**
  String get couldNotAccessStorage;

  /// Success message for data export
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get exportSuccessful;

  /// Message showing where data was exported
  ///
  /// In en, this message translates to:
  /// **'Your data has been exported to:'**
  String get dataExportedTo;

  /// Option to copy data directly
  ///
  /// In en, this message translates to:
  /// **'Or copy the data directly:'**
  String get copyDataDirectly;

  /// Button to copy data
  ///
  /// In en, this message translates to:
  /// **'Copy Data'**
  String get copyData;

  /// Message when data is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Data copied to clipboard'**
  String get dataCopiedToClipboard;

  /// Error message when export fails
  ///
  /// In en, this message translates to:
  /// **'Export Failed'**
  String get exportFailed;

  /// Error message for export failure
  ///
  /// In en, this message translates to:
  /// **'Failed to export data'**
  String get failedToExportData;

  /// Message for choosing import method
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to import your data:'**
  String get chooseImportMethod;

  /// Import from file option
  ///
  /// In en, this message translates to:
  /// **'From File'**
  String get fromFile;

  /// Description for file import
  ///
  /// In en, this message translates to:
  /// **'Select a backup file from your device'**
  String get selectBackupFile;

  /// Paste data option
  ///
  /// In en, this message translates to:
  /// **'Paste Data'**
  String get pasteData;

  /// Description for paste data import
  ///
  /// In en, this message translates to:
  /// **'Manually paste your backup data'**
  String get manuallyPasteData;

  /// Loading message while reading file
  ///
  /// In en, this message translates to:
  /// **'Reading file...'**
  String get readingFile;

  /// Error message when import fails
  ///
  /// In en, this message translates to:
  /// **'Import Failed'**
  String get importFailed;

  /// Error message for import failure
  ///
  /// In en, this message translates to:
  /// **'Failed to import data'**
  String get failedToImportData;

  /// Instructions for pasting data
  ///
  /// In en, this message translates to:
  /// **'Paste your backup data (JSON format) below:'**
  String get pasteDataDescription;

  /// Hint text for JSON data input
  ///
  /// In en, this message translates to:
  /// **'Paste your JSON backup data here...'**
  String get pasteJsonDataHint;

  /// Warning message for data replacement
  ///
  /// In en, this message translates to:
  /// **'Warning: This will replace all your current data!'**
  String get pasteDataWarning;

  /// Import button text
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Loading message while importing data
  ///
  /// In en, this message translates to:
  /// **'Importing data...'**
  String get importingData;

  /// Error message for invalid import data
  ///
  /// In en, this message translates to:
  /// **'Invalid import data format'**
  String get invalidImportData;

  /// Success message for data import
  ///
  /// In en, this message translates to:
  /// **'Import Successful'**
  String get importSuccessful;

  /// Success message for data import
  ///
  /// In en, this message translates to:
  /// **'Your data has been imported successfully'**
  String get dataImportedSuccessfully;

  /// Clear data button text
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// Success message when data is cleared
  ///
  /// In en, this message translates to:
  /// **'Data Cleared'**
  String get dataCleared;

  /// Message when all data is cleared
  ///
  /// In en, this message translates to:
  /// **'All your data has been permanently deleted'**
  String get allDataHasBeenCleared;

  /// Message about restarting app for changes
  ///
  /// In en, this message translates to:
  /// **'Some changes may require restarting the app to take full effect'**
  String get restartAppToApplyChanges;

  /// Restart app button text
  ///
  /// In en, this message translates to:
  /// **'Restart App'**
  String get restartApp;

  /// Message when daily reminders are enabled
  ///
  /// In en, this message translates to:
  /// **'Daily reminders enabled'**
  String get dailyRemindersEnabled;

  /// Message when daily reminders are disabled
  ///
  /// In en, this message translates to:
  /// **'Daily reminders disabled'**
  String get dailyRemindersDisabled;

  /// Message when streak notifications are enabled
  ///
  /// In en, this message translates to:
  /// **'Streak notifications enabled'**
  String get streakNotificationsEnabled;

  /// Message when streak notifications are disabled
  ///
  /// In en, this message translates to:
  /// **'Streak notifications disabled'**
  String get streakNotificationsDisabled;

  /// Message when notifications are enabled
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// Message showing the time daily reminders are set for
  ///
  /// In en, this message translates to:
  /// **'Daily habits reminder set for {time}'**
  String notificationsSetTime(String time);

  /// Message when notifications are disabled
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// Notification permission section header
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// Description for notification permission management
  ///
  /// In en, this message translates to:
  /// **'Manage notification permissions for the app'**
  String get notificationPermissionDescription;

  /// Title for the daily notification that checks for streak updates.
  ///
  /// In en, this message translates to:
  /// **'Workout Streak Update'**
  String get streakCheckTitle;

  /// No description provided for @streakMilestoneBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You\'ve maintained your workout streak. Keep up the great work!'**
  String get streakMilestoneBody;

  /// Title shown when a user hits a specific streak milestone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Day Streak!} other{{count} Day Streak!}}'**
  String streakMilestoneTitle(int count);

  /// No description provided for @dailyQuoteNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Quote of the Day'**
  String get dailyQuoteNotificationTitle;

  /// No description provided for @streakInfo.
  ///
  /// In en, this message translates to:
  /// **'Keep an eye on your daily streak here. It turns orange when all of today\'s habits are complete!'**
  String get streakInfo;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderInfo.
  ///
  /// In en, this message translates to:
  /// **'This choice will affect the weight increase suggested by the app and change the muscle heatmap diagram.'**
  String get genderInfo;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric (kg, km)'**
  String get metric;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (lbs, mi)'**
  String get imperial;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

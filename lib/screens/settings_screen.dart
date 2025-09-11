// lib/screens/settings_screen.dart

// import 'package:burnout/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import providers from new app structure
import '../providers/theme_settings_provider.dart';
import '../providers/language_provider.dart';
import '../providers/app_preferences_provider.dart'; // The new provider stub

// TODO: Import new notification service and data export/import logic when created

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification settings
  bool _dailyReminders = true;
  bool _streakNotifications = true;
  bool _quoteNotifications = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _streakNotificationsTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _quoteNotificationsTime = const TimeOfDay(hour: 9, minute: 0);
  // final NotificationService _notificationService = NotificationService();

  // Color data for theme selection
  final List<String> colors = [
    'red',
    'pink',
    'violet',
    'purple',
    'indigo',
    'blue',
    'lightBlue',
    'cyan',
    'teal',
    'green',
    'lightGreen',
    'lime',
    'yellow',
    'amber',
    'orange',
    'deepOrange',
    'brown',
    'gruvbox',
  ];

  final Map<String, Color> colorSwatches = {
    'red': Colors.red,
    'pink': Colors.pink,
    'violet': Colors.purple,
    'purple': Colors.deepPurple,
    'indigo': Colors.indigo,
    'blue': Colors.blue,
    'lightBlue': Colors.lightBlue,
    'cyan': Colors.cyan,
    'teal': Colors.teal,
    'green': Colors.green,
    'lightGreen': Colors.lightGreen,
    'lime': Colors.lime,
    'yellow': Colors.yellow,
    'amber': Colors.amber,
    'orange': Colors.orange,
    'deepOrange': Colors.deepOrange,
    'brown': Colors.brown,
    'gruvbox': Color(0xFF282828),
  };

  @override
  void initState() {
    super.initState();
    // Load initial settings when page opens. Providers handle their own loading.
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final themeSettings = context.watch<ThemeSettingsProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final appPrefs = context.watch<AppPreferencesProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Language Section ---
          _buildSectionHeader(context, l10n.language, Icons.language),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.languageSelection,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageOption(
                    context: context,
                    title: l10n.systemDefault,
                    languageValue: null,
                    groupValue: languageProvider.currentLocale,
                    onChanged:
                        (locale) => languageProvider.changeLanguage(locale),
                  ),
                  ...LanguageProvider.supportedLocales.map(
                    (locale) => _buildLanguageOption(
                      context: context,
                      title:
                          locale.languageCode == 'en'
                              ? 'English'
                              : 'Español', // Example name mapping
                      languageValue: locale,
                      groupValue: languageProvider.currentLocale,
                      onChanged:
                          (value) => languageProvider.changeLanguage(value),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- Appearance Section ---
          _buildSectionHeader(context, l10n.appearance, Icons.palette),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.themeMode,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildThemeOption(
                    context,
                    l10n.systemDefault,
                    AppThemeMode.system,
                    themeSettings.themeMode,
                    (v) => themeSettings.setThemeMode(v!),
                  ),
                  _buildThemeOption(
                    context,
                    l10n.lightMode,
                    AppThemeMode.light,
                    themeSettings.themeMode,
                    (v) => themeSettings.setThemeMode(v!),
                  ),
                  _buildThemeOption(
                    context,
                    l10n.darkMode,
                    AppThemeMode.dark,
                    themeSettings.themeMode,
                    (v) => themeSettings.setThemeMode(v!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.colorTheme,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        colors
                            .map(
                              (color) => _buildColorChip(
                                context,
                                color,
                                themeSettings.seedColor == color,
                                () => themeSettings.setSeedColor(color),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),

          _buildSectionHeader(context, l10n.notifications, Icons.notifications),

          // Showcase(
          //   key: _notificationsKey,
          //   description: l10n.notificationsTooltip,
          //   child:
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              // The 'children' property was missing here for the main Column.
              child: Column(
                children: [
                  // --- Section 1: Daily Reminders ---
                  _buildNotificationSetting(
                    context,
                    l10n.dailyReminders,
                    l10n.dailyRemindersDescription,
                    Icons.alarm,
                    _dailyReminders,
                    (value) {
                      setState(() {
                        _dailyReminders = value;
                      });
                      _saveNotificationSetting('daily_reminders', value);
                    },
                  ),
                  // Use Visibility instead of 'if' to avoid list index errors on rebuild
                  Visibility(
                    visible: _dailyReminders,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 56.0,
                        top: 4,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _dailyReminderTime.format(context),
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed:
                                () => _selectTimeForNotification(
                                  'daily_reminders',
                                ),
                            child: Text(_dailyReminderTime.format(context)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Section 2: Streak Notifications ---
                  _buildNotificationSetting(
                    context,
                    l10n.streakNotifications,
                    l10n.streakNotificationsDescription,
                    Icons.local_fire_department,
                    _streakNotifications,
                    (value) {
                      setState(() {
                        _streakNotifications = value;
                      });
                      _saveNotificationSetting('streak_notifications', value);
                    },
                  ),
                  // Use Visibility instead of 'if'
                  Visibility(
                    visible: _streakNotifications,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 56.0,
                        top: 4,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _streakNotificationsTime.format(context),
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed:
                                () => _selectTimeForNotification(
                                  'streak_notifications',
                                ),
                            child: Text(
                              _streakNotificationsTime.format(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Section 3: Quote Notifications ---
                  _buildNotificationSetting(
                    context,
                    l10n.quoteOfTheDay,
                    l10n.quoteOfTheDayDescription,
                    Icons.format_quote,
                    _quoteNotifications,
                    (value) {
                      setState(() {
                        _quoteNotifications = value;
                      });
                      _saveNotificationSetting('quote_notifications', value);
                    },
                  ),
                  // Use Visibility instead of 'if'
                  Visibility(
                    visible: _quoteNotifications,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 56.0,
                        top: 4,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _quoteNotificationsTime.format(context),
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed:
                                () => _selectTimeForNotification(
                                  'quote_notifications',
                                ),
                            child: Text(
                              _quoteNotificationsTime.format(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- TODO: Feature Sections to Re-implement ---
          // The sections below depend on features from your habit app that don't exist yet in the workout app.
          // They are commented out to allow the app to run. We can add them back one by one.

          // const SizedBox(height: 24),
          // _buildSectionHeader(context, l10n.features, Icons.toggle_on),
          // Card(
          //   elevation: 1,
          //   child: Column(
          //     children: [
          //       // TODO: Implement Quote feature logic if desired for workout app
          //       // SwitchListTile(
          //       //   title: Text(l10n.showQuotes),
          //       //   value: appPrefs.showQuotes,
          //       //   onChanged: (value) => appPrefs.updateQuotesSetting(value),
          //       // ),
          //       // TODO: Implement Mood Quiz feature logic if desired for workout app
          //       // SwitchListTile(
          //       //   title: Text(l10n.dailyMoodQuiz),
          //       //   value: appPrefs.showMoodQuiz,
          //       //   onChanged: (value) => appPrefs.updateMoodQuizSetting(value),
          //       // ),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 24),
          // _buildSectionHeader(context, l10n.notifications, Icons.notifications),
          // Card(
          //   elevation: 1,
          //   child: Padding(
          //     padding: const EdgeInsets.all(16),
          //     child: Column(
          //       children: [
          //         // TODO: Re-implement notification logic for workout streak reminders
          //         Text("Notification settings will go here."),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 24),

          // Data Import Export Section
          _buildSectionHeader(context, l10n.dataAndPrivacy, Icons.security),
          Card(
            elevation: 1,
            child: Column(
              children: [
                // TODO: Re-implement _exportData to export Hive boxes (routines, sessions)
                _buildDataOption(
                  context,
                  l10n.exportData,
                  l10n.exportDataDescription,
                  Icons.download,
                  () => _exportData(context),
                ),
                const Divider(height: 1),
                // TODO: Re-implement _importData to import into Hive boxes
                _buildDataOption(
                  context,
                  l10n.importData,
                  l10n.importDataDescription,
                  Icons.upload,
                  () => _importData(context),
                ),
                const Divider(height: 1),
                // TODO: Re-implement _clearAllData to clear Hive boxes
                _buildDataOption(
                  context,
                  l10n.clearAllData,
                  l10n.clearAllDataDescription,
                  Icons.delete_forever,
                  () => _clearAllData(context),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    // TODO: add data export
    return;
  }

  Future<void> _importData(BuildContext context) async {
    // TODO: add data import
    return;
  }

  Future<void> _clearAllData(BuildContext context) async {
    // TODO: delete all data
    return;
  }

  Future<void> _selectTimeForNotification(String notificationType) async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Determine which time to edit based on type
    TimeOfDay initialTime;
    String prefKey;
    switch (notificationType) {
      case 'daily_reminders':
        initialTime = _dailyReminderTime;
        prefKey = 'daily_reminder_time';
      case 'streak_notifications':
        initialTime = _streakNotificationsTime;
        prefKey = 'streak_notification_time';
      case 'quote_notifications':
        initialTime = _quoteNotificationsTime;
        prefKey = 'quote_notification_time';

      // Add a case for 'streak_notifications' if you implement it
      default:
        return;
    }

    // 2. Show time picker dialog (reusing your existing styled picker)
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              hourMinuteTextStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    // 3. Save new time and update state
    if (picked != null && picked != initialTime) {
      setState(() {
        if (notificationType == 'daily_reminders') {
          _dailyReminderTime = picked;
        } else if (notificationType == 'streak_notifications') {
          _streakNotificationsTime = picked;
        } else if (notificationType == 'quote_notifications') {
          _quoteNotificationsTime = picked;
        }
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        prefKey,
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );

      // Reschedule notifications with new time
      // await _notificationService.updateNotificationSettings();

      // Show confirmation
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notificationsSetTime(picked.format(context))),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load daily reminder time
    final dailyTimeString = prefs.getString('daily_reminder_time') ?? '09:00';
    final dailyParts = dailyTimeString.split(':');
    final dailyHour = int.parse(dailyParts[0]);
    final dailyMinute = int.parse(dailyParts[1]);

    final streakTimeString =
        prefs.getString('streak_notification_time') ??
        '12:00'; // Use correct key and different default
    final streakParts = streakTimeString.split(':');
    final streakHour = int.parse(streakParts[0]);
    final streakMinute = int.parse(streakParts[1]);

    setState(() {
      _dailyReminders = prefs.getBool('daily_reminders') ?? true;
      _streakNotifications = prefs.getBool('streak_notifications') ?? true;

      _dailyReminderTime = TimeOfDay(hour: dailyHour, minute: dailyMinute);
      _streakNotificationsTime = TimeOfDay(
        hour: streakHour,
        minute: streakMinute,
      ); // Use streakHour/streakMinute
    });
  }

  // --- Reusable Widget Builders ---

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required Locale? languageValue,
    required Locale? groupValue,
    required Function(Locale?) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Radio<Locale?>(
        value: languageValue,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => onChanged(languageValue),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    AppThemeMode value,
    AppThemeMode groupValue,
    Function(AppThemeMode?) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Radio<AppThemeMode>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => onChanged(value),
    );
  }

  Widget _buildColorChip(
    BuildContext context,
    String colorName,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final color = colorSwatches[colorName] ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
            width: 3,
          ),
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
      ),
    );
  }

  Widget _buildNotificationSetting(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) async {
          // Check permissions before enabling notifications
          if (newValue) {
            await _checkNotificationPermissions();
          }
          onChanged(newValue);
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDataOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isDestructive ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildAboutOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: onTap != null ? Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  String _getLanguageDescription(AppLocalizations l10n, String languageCode) {
    switch (languageCode) {
      case 'en':
        return l10n.englishLanguageDescription;
      case 'es':
        return l10n.spanishLanguageDescription;
      case 'fr':
        return l10n.frenchLanguageDescription;
      default:
        return '';
    }
  }

  IconData _getLanguageIcon(String languageCode) {
    switch (languageCode) {
      case 'en':
        return Icons.language;
      case 'es':
        return Icons.language;
      case 'fr':
        return Icons.language;
      default:
        return Icons.language;
    }
  }

  Future<void> _checkNotificationPermissions() async {
    // final hasPermission = await NotificationService().areNotificationsEnabled();

    // if (!hasPermission) {
    //   final l10n = AppLocalizations.of(context)!;
    //   showDialog(
    //     context: context,
    //     builder:
    //         (context) => AlertDialog(
    //           title: Row(
    //             children: [
    //               Icon(Icons.notifications_off, color: Colors.orange),
    //               SizedBox(width: 8),
    //               Text(l10n.notificationPermission),
    //             ],
    //           ),
    //           content: Text(l10n.notificationPermissionDescription),
    //           actions: [
    //             TextButton(
    //               onPressed: () => Navigator.pop(context),
    //               child: Text(l10n.ok),
    //             ),
    //           ],
    //         ),
    //   );
    // }
  }

  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    // Update notification schedules when settings change
    // await NotificationService().updateNotificationSettings();

    // Show status message
    final l10n = AppLocalizations.of(context)!;
    String message;

    switch (key) {
      case 'daily_reminders':
        if (value) {
          // await NotificationService().scheduleDailyHabitsNotification();
          return;
        } else {
          // await NotificationService().cancelDailyReminderNotification();
          return;
        }
        message =
            value ? l10n.dailyRemindersEnabled : l10n.dailyRemindersDisabled;
        break;

      case 'streak_notifications':
        message =
            value
                ? l10n.streakNotificationsEnabled
                : l10n.streakNotificationsDisabled;
        break;

      default:
        message =
            value ? l10n.notificationsEnabled : l10n.notificationsDisabled;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }
}

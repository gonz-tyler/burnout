// lib/screens/settings_screen.dart

// import 'package:burnout/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import providers from new app structure
import '../providers/theme_settings_provider.dart';
import '../providers/language_provider.dart';
import '../providers/app_preferences_provider.dart';
import '../providers/gender_settings_provider.dart'; // Fixed missing semicolon
import '../providers/unit_settings_provider.dart'; // Added Unit Provider

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
    'purple',
    'violet',
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
    'autumn',
  ];

  final Map<String, Color> colorSwatches = {
    'red': Colors.red,
    'pink': Colors.pink,
    'purple': Colors.purple,
    'violet': Colors.deepPurple,
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
    'autumn': Color(0xFF282828),
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
    final genderSettings = context.watch<GenderSettingsProvider>();
    final unitSettings = context.watch<UnitSettingsProvider>();
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

          const SizedBox(height: 24),

          // --- Body Settings Section ---
          _buildSectionHeader(context, l10n.body, Icons.accessibility_new),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Units Selection
                  Text(
                    "Measurement System", // Consider moving this to AppLocalizations
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUnitOption(
                    context,
                    l10n.metric,
                    UnitSystem.metric,
                    unitSettings,
                  ),
                  _buildUnitOption(
                    context,
                    l10n.imperial,
                    UnitSystem.imperial,
                    unitSettings,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 24),
                  ),

                  // Gender Selection
                  Text(
                    l10n.gender,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.genderInfo,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGenderOption(
                    context,
                    l10n.male,
                    Gender.male,
                    genderSettings,
                  ),
                  _buildGenderOption(
                    context,
                    l10n.female,
                    Gender.female,
                    genderSettings,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Data Import Export Section
          _buildSectionHeader(context, l10n.dataAndPrivacy, Icons.security),
          Card(
            elevation: 1,
            child: Column(
              children: [
                _buildDataOption(
                  context,
                  l10n.exportData,
                  l10n.exportDataDescription,
                  Icons.download,
                  () => _exportData(context),
                ),
                const Divider(height: 1),
                _buildDataOption(
                  context,
                  l10n.importData,
                  l10n.importDataDescription,
                  Icons.upload,
                  () => _importData(context),
                ),
                const Divider(height: 1),
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
      default:
        return;
    }

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
            timePickerTheme: const TimePickerThemeData(
              hourMinuteTextStyle: TextStyle(
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

    final dailyTimeString = prefs.getString('daily_reminder_time') ?? '09:00';
    final dailyParts = dailyTimeString.split(':');
    final dailyHour = int.parse(dailyParts[0]);
    final dailyMinute = int.parse(dailyParts[1]);

    final streakTimeString =
        prefs.getString('streak_notification_time') ?? '12:00';
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
      );
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

  // Helper method for Gender Options
  Widget _buildGenderOption(
    BuildContext context,
    String title,
    Gender value,
    GenderSettingsProvider provider,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Radio<Gender>(
        value: value,
        groupValue: provider.gender,
        onChanged: (newValue) {
          if (newValue != null) provider.setGender(newValue);
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => provider.setGender(value),
    );
  }

  // Helper method for Unit Options
  Widget _buildUnitOption(
    BuildContext context,
    String title,
    UnitSystem value,
    UnitSettingsProvider provider,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Radio<UnitSystem>(
        value: value,
        groupValue: provider.unitSystem,
        onChanged: (newValue) {
          if (newValue != null) provider.setUnitSystem(newValue);
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => provider.setUnitSystem(value),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) async {
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      case 'es':
      case 'fr':
      default:
        return Icons.language;
    }
  }

  Future<void> _checkNotificationPermissions() async {
    // Permission logic goes here
  }

  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    final l10n = AppLocalizations.of(context)!;
    String message;

    switch (key) {
      case 'daily_reminders':
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

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

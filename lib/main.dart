// lib/main.dart
import 'dart:convert';

import 'package:burnout/providers/app_preferences_provider.dart';
import 'package:burnout/providers/language_provider.dart';
import 'package:burnout/providers/theme_settings_provider.dart';
import 'package:burnout/providers/user_settings_provider.dart';
import 'package:burnout/repositories/workout_repository.dart';
import 'package:burnout/screens/main_screen.dart';
import 'package:burnout/screens/settings_screen.dart';
import 'package:burnout/services/streak_service.dart';
import 'package:burnout/viewmodels/workout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Import model files to access classes and generated adapters
import 'models/enums.dart';
import 'models/exercise.dart';
import 'models/routine.dart';
import 'models/workout_plan.dart';
import 'models/workout_session.dart';
import 'models/planned_set.dart';

// Define box names as constants for easy reuse
const String exerciseBoxName = 'exercises';
const String routineBoxName = 'routines';
const String workoutSessionBoxName = 'workoutSessions';
const String planBoxName = 'workoutPlans';

Future<void> main() async {
  // Initialize Flutter binding and Hive
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register all TypeAdapters
  Hive.registerAdapter(SetTypeAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(RoutineAdapter());
  Hive.registerAdapter(RoutineExerciseAdapter());
  Hive.registerAdapter(PlannedSetAdapter());
  Hive.registerAdapter(WorkoutPlanAdapter());
  Hive.registerAdapter(WorkoutSessionAdapter());
  Hive.registerAdapter(PerformedExerciseAdapter());
  Hive.registerAdapter(PerformedSetAdapter());

  // Open Hive Boxes
  await Hive.openBox<Exercise>(exerciseBoxName);
  await Hive.openBox<Routine>(routineBoxName);
  await Hive.openBox<WorkoutSession>(workoutSessionBoxName);
  await Hive.openBox<WorkoutPlan>(planBoxName);

  // Run your application
  final workoutRepository = WorkoutRepository();
  final streakService = StreakService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AppPreferencesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeSettingsProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create:
              (_) => WorkoutViewModel(
                workoutRepository: workoutRepository,
                streakService: streakService,
              ),
        ),
      ],
      child: const WorkoutApp(),
    ),
  );
}

class WorkoutApp extends StatefulWidget {
  const WorkoutApp({Key? key}) : super(key: key);

  @override
  State<WorkoutApp> createState() => _WorkoutAppState();
}

class _WorkoutAppState extends State<WorkoutApp> {
  // Cache themes to avoid reloading from disk on every rebuild
  static final Map<String, ThemeData> _themeCache = {};

  Future<ThemeData> _loadTheme(String path) async {
    if (_themeCache.containsKey(path)) {
      return _themeCache[path]!;
    }
    try {
      final themeStr = await rootBundle.loadString(path);
      final themeJson = jsonDecode(themeStr);
      final theme = ThemeDecoder.decodeThemeData(themeJson)!;
      _themeCache[path] = theme;
      return theme;
    } catch (e) {
      debugPrint("Error loading theme from $path: $e");
      // Fallback to default theme if file loading fails
      return ThemeData.light();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeSettingsProvider, LanguageProvider>(
      builder: (context, themeSettings, languageProvider, _) {
        // Define theme paths based on provider state
        String seed = themeSettings.seedColor;
        String lightPath = 'assets/themes/appainter_${seed}_light.json';
        String darkPath = 'assets/themes/appainter_${seed}_dark.json';

        return FutureBuilder<List<ThemeData>>(
          future: Future.wait([_loadTheme(lightPath), _loadTheme(darkPath)]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Show a simple loading indicator while themes load
              return const MaterialApp(home: CircularProgressIndicator());
            }

            final lightTheme = snapshot.data![0];
            final darkTheme = snapshot.data![1];

            ThemeMode mode;
            switch (themeSettings.themeMode) {
              case AppThemeMode.light:
                mode = ThemeMode.light;
                break;
              case AppThemeMode.dark:
                mode = ThemeMode.dark;
                break;
              default:
                mode = ThemeMode.system;
            }

            return MaterialApp(
              title: 'ProjectOut Workout Tracker',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: mode,
              // --- Dynamic Localization ---
              locale: languageProvider.currentLocale, // Set locale dynamically
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LanguageProvider.supportedLocales,
              home: const MainScreen(), // The screen with bottom navigation
              debugShowCheckedModeBanner: false,
              routes: {'/settings': (context) => const SettingsScreen()},
            );
          },
        );
      },
    );
  }
}

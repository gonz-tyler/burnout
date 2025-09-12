// lib/main.dart
import 'dart:convert';
import 'package:burnout/models/exercise.dart';
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

import 'models/models.dart';

// Box names
const String exerciseBoxName = 'exercises';
const String routineBoxName = 'routines';
const String workoutSessionBoxName = 'workoutSessions';
const String planBoxName = 'workoutPlans';

Future<void> main() async {
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

  // **THIS IS THE FIX**: Load initial data if it's the first launch
  await _loadInitialData();

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

// **UPDATED FUNCTION**: Now checks if the exercise box is empty, which is more reliable.
Future<void> _loadInitialData() async {
  final exerciseBox = Hive.box<Exercise>(exerciseBoxName);

  // Only load data if the box is empty.
  if (exerciseBox.isEmpty) {
    debugPrint("Exercise box is empty. Loading exercises from JSON...");
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/standardized_exercises.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final exercises =
          jsonList.map((json) => Exercise.fromJson(json)).toList();

      final Map<String, Exercise> exerciseMap = {
        for (var e in exercises) e.id: e,
      };
      await exerciseBox.putAll(exerciseMap);

      debugPrint(
        "Successfully loaded ${exercises.length} exercises into Hive.",
      );
    } catch (e) {
      debugPrint("Error loading initial exercises: $e");
    }
  } else {
    debugPrint(
      "Exercise box already has data (${exerciseBox.length} exercises). Skipping initial load.",
    );
  }
}

class WorkoutApp extends StatefulWidget {
  const WorkoutApp({Key? key}) : super(key: key);

  @override
  State<WorkoutApp> createState() => _WorkoutAppState();
}

class _WorkoutAppState extends State<WorkoutApp> {
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
      return ThemeData.light();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeSettingsProvider, LanguageProvider>(
      builder: (context, themeSettings, languageProvider, _) {
        String seed = themeSettings.seedColor;
        String lightPath = 'assets/themes/appainter_${seed}_light.json';
        String darkPath = 'assets/themes/appainter_${seed}_dark.json';

        return FutureBuilder<List<ThemeData>>(
          future: Future.wait([_loadTheme(lightPath), _loadTheme(darkPath)]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
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
              title: 'Burnout Workout Tracker',
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                scrollbars: false,
              ),
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: mode,
              locale: languageProvider.currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LanguageProvider.supportedLocales,
              home: const MainScreen(),
              debugShowCheckedModeBanner: false,
              routes: {'/settings': (context) => const SettingsScreen()},
            );
          },
        );
      },
    );
  }
}

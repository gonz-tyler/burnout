import 'dart:math';

import 'package:burnout/models/exercise.dart';
import 'package:burnout/models/workout_session.dart';

class MuscleAnalysisService {
  // Maps specific muscle names from JSON to general SVG path IDs
  static const Map<String, String> _muscleMapping = {
    // Chest
    'Pectoralis Major': 'Chest',
    'Pectoralis Major (Upper)': 'Chest',
    // Back
    'Latissimus Dorsi': 'Lats',
    'Trapezius': 'Trapezius',
    'Rhomboids': 'Trapezius',
    'Erector Spinae': 'Lower_Back',
    // Shoulders
    'Deltoid (Anterior)': 'Delts',
    'Deltoid (Lateral)': 'Delts',
    'Deltoid (General)': 'Delts',
    'Deltoid (Posterior)': 'Deltoids_Posterior',
    // Arms
    'Biceps Brachii': 'Biceps',
    'Triceps Brachii': 'Triceps',
    'Forearm Muscles': 'Forearms',
    'Forearm Flexors': 'Forearms',
    'Forearm Extensors': 'Forearms_Back',
    // Legs
    'Quadriceps': 'Quads',
    'Hamstrings': 'Hamstrings',
    'Adductors': 'Adductors',
    'Calves': 'Calves',
    'Gastrocnemius': 'Calves',
    'Soleus': 'Calves',
    'Tibialis Anterior': 'Tibialis',
    'Abductors': 'Abductors',
    // Glutes
    'Gluteus Maximus': 'Glutes',
    'Gluteus Medius': 'Glutes',
    // Core
    'Rectus Abdominis': 'Abs',
    'Obliques': 'Obliques',
    'Hip Flexors': 'Abs',
  };

  static Map<String, double> _calculateIntensity(
    List<WorkoutSession> sessions,
    List<Exercise> allExercises,
  ) {
    final Map<String, double> totalVolumeByMuscle = {};

    // Create a lookup map for faster exercise access
    final exerciseMap = {for (var e in allExercises) e.id: e};

    for (final session in sessions) {
      for (final pExercise in session.performedExercises) {
        final exercise = exerciseMap[pExercise.exerciseId];
        if (exercise == null || exercise.targetedMuscles == null) continue;

        double exerciseVolume = 0;
        for (final set in pExercise.sets) {
          // Use a fallback of 1 for reps if it's null (e.g., for timed sets)
          exerciseVolume += (set.weight ?? 0) * (set.reps ?? 1);
        }

        exercise.targetedMuscles!.forEach((muscleName, percentage) {
          final svgMuscleGroup = _muscleMapping[muscleName];
          if (svgMuscleGroup != null) {
            totalVolumeByMuscle.update(
              svgMuscleGroup,
              (currentVolume) => currentVolume + (exerciseVolume * percentage),
              ifAbsent: () => exerciseVolume * percentage,
            );
          }
        });
      }
    }

    // Normalize the values to a 0.0 - 1.0 scale for intensity
    final maxVolume = totalVolumeByMuscle.values.fold(
      0.0,
      (prev, element) => max(prev, element),
    );

    if (maxVolume == 0) return {};

    return totalVolumeByMuscle.map(
      (key, value) => MapEntry(key, value / maxVolume),
    );
  }

  static Map<String, double> getWeeklyMuscleIntensity(
    List<WorkoutSession> sessions,
    List<Exercise> allExercises,
  ) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentSessions =
        sessions.where((s) => s.dateCompleted.isAfter(sevenDaysAgo)).toList();
    return _calculateIntensity(recentSessions, allExercises);
  }

  static Map<String, double> getMonthlyMuscleIntensity(
    List<WorkoutSession> sessions,
    List<Exercise> allExercises,
  ) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentSessions =
        sessions.where((s) => s.dateCompleted.isAfter(thirtyDaysAgo)).toList();
    return _calculateIntensity(recentSessions, allExercises);
  }

  static Map<String, double> getAllTimeMuscleIntensity(
    List<WorkoutSession> sessions,
    List<Exercise> allExercises,
  ) {
    // No date filtering, so we pass all sessions
    return _calculateIntensity(sessions, allExercises);
  }

  static Map<String, double> getComparativeMuscleBalance(
    List<WorkoutSession> sessions,
    List<Exercise> allExercises,
  ) {
    // A simple agonist/antagonist balance check
    final intensity = _calculateIntensity(sessions, allExercises);
    if (intensity.isEmpty) return {};

    final pushMuscles = ['Chest', 'Deltoids', 'Triceps'];
    final pullMuscles = ['Lats', 'Trapezius', 'Biceps', 'Deltoids_Posterior'];
    final legPush = ['Quads'];
    final legPull = ['Hamstrings', 'Glutes'];

    double pushScore = pushMuscles.fold(
      0.0,
      (sum, m) => sum + (intensity[m] ?? 0.0),
    );
    double pullScore = pullMuscles.fold(
      0.0,
      (sum, m) => sum + (intensity[m] ?? 0.0),
    );
    double legPushScore = legPush.fold(
      0.0,
      (sum, m) => sum + (intensity[m] ?? 0.0),
    );
    double legPullScore = legPull.fold(
      0.0,
      (sum, m) => sum + (intensity[m] ?? 0.0),
    );

    final Map<String, double> balanceMap = {};

    // Highlight push muscles with their score, pull with theirs
    for (var m in pushMuscles) {
      balanceMap[m] = pushScore;
    }
    for (var m in pullMuscles) {
      balanceMap[m] = pullScore;
    }
    for (var m in legPush) {
      balanceMap[m] = legPushScore;
    }
    for (var m in legPull) {
      balanceMap[m] = legPullScore;
    }

    // Normalize again
    final maxScore = balanceMap.values.fold(0.0, (p, c) => max(p, c));
    if (maxScore == 0) return {};
    return balanceMap.map((key, value) => MapEntry(key, value / maxScore));
  }

  static List<String> getMuscleImbalanceWarnings(
    Map<String, double> intensity,
  ) {
    List<String> warnings = [];
    if (intensity.isEmpty) return warnings;

    final chest = intensity['Chest'] ?? 0.0;
    final back = (intensity['Lats'] ?? 0.0) + (intensity['Trapezius'] ?? 0.0);
    final biceps = intensity['Biceps'] ?? 0.0;
    final triceps = intensity['Triceps'] ?? 0.0;
    final quads = intensity['Quads'] ?? 0.0;
    final hamstrings = intensity['Hamstrings'] ?? 0.0;

    if (chest > back * 1.5) {
      warnings.add(
        "Push-dominant: Your chest volume significantly exceeds your back volume. Consider adding more rows or pull-ups.",
      );
    }
    if (back > chest * 1.5) {
      warnings.add(
        "Pull-dominant: Your back volume significantly exceeds your chest volume. Ensure you're incorporating enough pressing movements.",
      );
    }
    if (quads > hamstrings * 1.5) {
      warnings.add(
        "Quad-dominant: Your quads are much stronger than your hamstrings. Add Romanian deadlifts or leg curls to prevent injury.",
      );
    }
    if (biceps > triceps * 1.2) {
      warnings.add(
        "Your bicep volume is higher than triceps. Stronger triceps contribute to bigger presses and arm size.",
      );
    }

    return warnings;
  }
}

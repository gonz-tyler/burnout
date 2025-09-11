// lib/repositories/workout_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import '../models/models.dart';
import 'package:collection/collection.dart';

// Re-use box names defined in main.dart or define them here again
const String exerciseBoxName = 'exercises';
const String routineBoxName = 'routines';
const String workoutSessionBoxName = 'workoutSessions';

class WorkoutRepository {
  /// Loads exercises from the local JSON asset file into the Hive box.
  /// This should be run once on first app launch.
  Future<void> loadExercisesFromJson() async {
    final Box<Exercise> exerciseBox = Hive.box<Exercise>(exerciseBoxName);

    // Only load if the box is empty to avoid duplicates on subsequent launches
    if (exerciseBox.isEmpty) {
      final String jsonString = await rootBundle.loadString(
        'assets/data/standardized_exercises.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      final Map<String, Exercise> exerciseMap = {};
      for (var jsonItem in jsonList) {
        final exercise = Exercise.fromJson(jsonItem);
        exerciseMap[exercise.id] = exercise; // Use exercise ID as key
      }

      await exerciseBox.putAll(exerciseMap);
    }
  }

  PerformedExercise? getPreviousPerformance(String exerciseId) {
    final allSessions = getAllWorkoutSessions();

    // Use lastWhereOrNull to safely find the session or return null
    final lastSessionWithExercise = allSessions.lastWhereOrNull(
      (session) =>
          session.performedExercises.any((pe) => pe.exerciseId == exerciseId),
    );

    if (lastSessionWithExercise == null) {
      return null;
    }

    return lastSessionWithExercise.performedExercises.firstWhereOrNull(
      (pe) => pe.exerciseId == exerciseId,
    );
  }

  /// Retrieves all exercises stored in the database.
  List<Exercise> getAllExercises() {
    final Box<Exercise> exerciseBox = Hive.box<Exercise>(exerciseBoxName);
    return exerciseBox.values.toList();
  }

  // --- Workout Session Management ---

  /// Saves a new workout session to the database.
  Future<void> saveWorkoutSession(WorkoutSession session) async {
    final Box<WorkoutSession> sessionBox = Hive.box<WorkoutSession>(
      workoutSessionBoxName,
    );
    // 'add' generates an auto-incrementing integer key, suitable for simple local storage.
    await sessionBox.add(session);
  }

  /// Retrieves all historical workout sessions, sorted by date.
  List<WorkoutSession> getAllWorkoutSessions() {
    final Box<WorkoutSession> sessionBox = Hive.box<WorkoutSession>(
      workoutSessionBoxName,
    );
    final sessions = sessionBox.values.toList();
    // Sort by date ascending to prepare for streak calculation
    sessions.sort((a, b) => a.dateCompleted.compareTo(b.dateCompleted));
    return sessions;
  }

  // --- Routine Management (Example) ---

  /// Retrieves all user-created routines from the database.
  List<Routine> getAllRoutines() {
    final Box<Routine> routineBox = Hive.box<Routine>(routineBoxName);
    return routineBox.values.toList();
  }

  /// Saves a user-created routine.
  Future<void> saveRoutine(Routine routine) async {
    final Box<Routine> routineBox = Hive.box<Routine>(routineBoxName);
    await routineBox.put(routine.id, routine);
  }

  /// Deletes a routine by its ID.
  Future<void> deleteRoutine(String routineId) async {
    final Box<Routine> routineBox = Hive.box<Routine>(routineBoxName);
    await routineBox.delete(routineId);
  }
}

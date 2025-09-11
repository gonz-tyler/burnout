// lib/viewmodels/active_workout_view_model.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart'; // Or wherever your models are

class ActiveWorkoutViewModel extends ChangeNotifier {
  // --- STATE ---
  late Routine _routine; // The routine template we're working from
  late WorkoutSession _currentSession; // The workout log we are building
  final Map<int, List<PerformedSet>> _performedSetsData = {};
  final Map<int, List<bool>> _setCompletionStatus = {};

  int _currentExerciseIndex = 0;
  bool _isWorkoutStarted = false;

  // --- GETTERS (for the UI to read) ---
  bool get isWorkoutStarted => _isWorkoutStarted;
  RoutineExercise get currentExercise =>
      _routine.exercises[_currentExerciseIndex];
  int get currentExerciseIndex => _currentExerciseIndex;
  int get totalExercises => _routine.exercises.length;

  // --- ACTIONS ---

  // Called when the user presses "Start Routine"
  void startWorkout(Routine routine) {
    _routine = routine;
    _currentExerciseIndex = 0;

    // Create a new session object
    _currentSession = WorkoutSession(
      id: const Uuid().v4(),
      routineId: routine.id,
      dateCompleted: DateTime.now(), // Will be updated at the end
      durationInMinutes: 0, // Will be calculated at the end
      performedExercises: [],
    );

    // Initialize the state for each set when the workout starts
    _performedSetsData.clear();
    _setCompletionStatus.clear();
    for (int i = 0; i < routine.exercises.length; i++) {
      final exercise = routine.exercises[i];
      // Pre-fill with planned data
      _performedSetsData[i] =
          exercise.plannedSets
              .map(
                (ps) => PerformedSet(
                  setType: ps.setType,
                  reps:
                      ps.targetReps != null
                          ? int.tryParse(ps.targetReps!)
                          : null,
                  weight: ps.targetWeight,
                ),
              )
              .toList();
      // All sets start as incomplete
      _setCompletionStatus[i] = List.generate(
        exercise.plannedSets.length,
        (_) => false,
      );
    }

    _isWorkoutStarted = true;
    notifyListeners();
  }

  bool isSetCompleted(int exerciseIndex, int setIndex) {
    return _setCompletionStatus[exerciseIndex]?[setIndex] ?? false;
  }

  // NEW METHOD: Update the data for a set as the user types
  void updateSetData(int exerciseIndex, int setIndex, double weight, int reps) {
    if (_performedSetsData[exerciseIndex] != null &&
        _performedSetsData[exerciseIndex]!.length > setIndex) {
      final oldSet = _performedSetsData[exerciseIndex]![setIndex];
      _performedSetsData[exerciseIndex]![setIndex] = PerformedSet(
        setType: oldSet.setType,
        weight: weight,
        reps: reps,
      );
      // No need to call notifyListeners() here, as the text fields handle their own state
    }
  }

  // NEW METHOD: Toggle the completion status of a set
  void completeSet(int exerciseIndex, int setIndex) {
    if (_setCompletionStatus[exerciseIndex] != null &&
        _setCompletionStatus[exerciseIndex]!.length > setIndex) {
      _setCompletionStatus[exerciseIndex]![setIndex] =
          !_setCompletionStatus[exerciseIndex]![setIndex];
      notifyListeners();
      // TODO: Start a rest timer here later
    }
  }

  // TODO: Add methods for moving to the next exercise and finishing the workout.
}

// lib/viewmodels/active_workout_view_model.dart

import 'package:flutter/material.dart';
import '../models/models.dart';

class ActiveWorkoutViewModel extends ChangeNotifier {
  Routine? _routine;
  bool _isWorkoutStarted = false;
  final List<RoutineExercise> _liveExercises = [];
  final Map<String, bool> _setCompletionStatus = {};

  // Map to track the weight mode for each exercise by its ID.
  final Map<String, WeightMode> _exerciseWeightModes = {};

  // --- GETTERS ---
  bool get isWorkoutStarted => _isWorkoutStarted;
  List<RoutineExercise> get liveExercises => _liveExercises;
  Routine? get routine => _routine;

  // --- ACTIONS ---
  void startWorkout(Routine routine) {
    _routine = routine;
    _liveExercises.clear();
    _liveExercises.addAll(routine.exercises.map((e) => e.copyWith()).toList());
    _setCompletionStatus.clear();
    _exerciseWeightModes.clear();

    // 🟢 FIX 1: Smart Detect Mode
    // Scan the exercises. If we find negative weight, force "Assisted" mode immediately.
    for (var exercise in _liveExercises) {
      // Check if any set has a negative weight (indicates Assisted)
      bool hasNegativeWeight = exercise.plannedSets.any(
        (s) => (s.targetWeight ?? 0) < 0,
      );

      if (hasNegativeWeight) {
        _exerciseWeightModes[exercise.exerciseId] = WeightMode.assisted;
      } else {
        // Otherwise, leave it null (getWeightModeForExercise will handle the default)
        // or specifically check for Bodyweight (0kg) if you want strict checking.
      }
    }

    _isWorkoutStarted = true;
    notifyListeners();
  }

  String _getSetKey(int exerciseIndex, int setIndex) {
    final exerciseId = _liveExercises[exerciseIndex].exerciseId;
    return 'e${exerciseId}s$setIndex';
  }

  // Get the current weight mode for an exercise.
  WeightMode getWeightModeForExercise(Exercise exercise) {
    if (!_exerciseWeightModes.containsKey(exercise.id)) {
      // Default fallback if not set during startWorkout
      if (exercise.supportsWeight) {
        return WeightMode.weighted;
      } else if (exercise.supportsBodyweight) {
        return WeightMode.bodyweight;
      } else if (exercise.supportsAssistance) {
        return WeightMode.assisted;
      }
    }
    return _exerciseWeightModes[exercise.id] ?? WeightMode.weighted;
  }

  // The logic to cycle through available weight modes.
  void cycleWeightModeForExercise(int exerciseIndex, Exercise exerciseDetails) {
    final modes = <WeightMode>[
      if (exerciseDetails.supportsWeight) WeightMode.weighted,
      if (exerciseDetails.supportsBodyweight) WeightMode.bodyweight,
      if (exerciseDetails.supportsAssistance) WeightMode.assisted,
    ];

    if (modes.length < 2) return;

    final currentMode = getWeightModeForExercise(exerciseDetails);
    final currentIndex = modes.indexOf(currentMode);
    final nextMode = modes[(currentIndex + 1) % modes.length];

    _exerciseWeightModes[exerciseDetails.id] = nextMode;

    // Update the weights of all sets for this exercise
    final routineExercise = _liveExercises[exerciseIndex];
    for (int i = 0; i < routineExercise.plannedSets.length; i++) {
      final currentSet = routineExercise.plannedSets[i];
      double newWeight;

      // 🟢 FIX 2: Better conversion logic to prevent data loss on 0s
      double currentAbs = currentSet.targetWeight?.abs() ?? 0.0;
      // If conversion is stuck at 0, default to a sensible number (e.g. 10 or 20)
      // so the user doesn't have to type from scratch.
      if (currentAbs == 0) currentAbs = 0;

      switch (nextMode) {
        case WeightMode.weighted:
          newWeight = currentAbs;
          break;
        case WeightMode.bodyweight:
          newWeight = 0;
          break;
        case WeightMode.assisted:
          // If we are switching TO assisted, ensure it is negative
          // If current was 0, maybe default to -10 just to show it's working?
          // For now, -0 is technically 0, but let's keep strict negation.
          newWeight = -currentAbs;
          break;
      }
      _liveExercises[exerciseIndex].plannedSets[i] = currentSet.copyWith(
        targetWeight: newWeight,
      );
    }

    notifyListeners();
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex >= _liveExercises.length) return;

    final exercise = _liveExercises[exerciseIndex];
    if (setIndex >= exercise.plannedSets.length) return;

    exercise.plannedSets.removeAt(setIndex);

    // Note: We are relying on the UI to rebuild keys, so we just notify here.
    notifyListeners();
  }

  bool isSetCompleted(int exerciseIndex, int setIndex) {
    return _setCompletionStatus[_getSetKey(exerciseIndex, setIndex)] ?? false;
  }

  void toggleSetCompletion(int exerciseIndex, int setIndex) {
    final key = _getSetKey(exerciseIndex, setIndex);
    _setCompletionStatus[key] = !(_setCompletionStatus[key] ?? false);
    notifyListeners();
  }

  void updateSetData(int exerciseIndex, int setIndex, PlannedSet updatedSet) {
    if (exerciseIndex < _liveExercises.length &&
        setIndex < _liveExercises[exerciseIndex].plannedSets.length) {
      _liveExercises[exerciseIndex].plannedSets[setIndex] = updatedSet;
    }
  }

  void addExercise(RoutineExercise newExercise) {
    _liveExercises.add(newExercise);

    // Auto-detect if it needs assisted mode (like we do in startWorkout)
    bool hasNegativeWeight = newExercise.plannedSets.any(
      (s) => (s.targetWeight ?? 0) < 0,
    );
    if (hasNegativeWeight) {
      _exerciseWeightModes[newExercise.exerciseId] = WeightMode.assisted;
    }

    notifyListeners();
  }

  // 🟢 NEW: Remove an exercise entirely from the active workout
  void deleteExercise(int index) {
    if (index >= 0 && index < _liveExercises.length) {
      _liveExercises.removeAt(index);
      // 🟢 CRITICAL: Notify listeners so the UI rebuilds!
      notifyListeners();
    }
  }

  // 🟢 NEW: Check if the routine has changed compared to the original
  // Used to show the "Update Routine?" dialog
  bool hasRoutineChanged() {
    if (_routine == null) return false;

    // Check lengths
    if (_liveExercises.length != _routine!.exercises.length) return true;

    // Check IDs in order
    for (int i = 0; i < _liveExercises.length; i++) {
      if (_liveExercises[i].exerciseId != _routine!.exercises[i].exerciseId) {
        return true;
      }
    }
    return false;
  }

  double get workoutProgress {
    if (_routine == null) return 0;
    final totalSets = _liveExercises.fold<int>(
      0,
      (sum, ex) => sum + ex.plannedSets.length,
    );
    if (totalSets == 0) return 0;
    final completedSets =
        _setCompletionStatus.values.where((completed) => completed).length;
    return completedSets / totalSets;
  }

  List<PerformedExercise> getPerformedExercises() {
    List<PerformedExercise> performed = [];
    for (int i = 0; i < _liveExercises.length; i++) {
      final routineExercise = _liveExercises[i];
      final performedSets = <PerformedSet>[];

      for (int j = 0; j < routineExercise.plannedSets.length; j++) {
        if (isSetCompleted(i, j)) {
          final plannedSet = routineExercise.plannedSets[j];
          performedSets.add(
            PerformedSet(
              setType: plannedSet.setType,
              reps: int.tryParse(plannedSet.targetReps ?? ''),
              weight: plannedSet.targetWeight,
            ),
          );
        }
      }

      if (performedSets.isNotEmpty) {
        performed.add(
          PerformedExercise(
            exerciseId: routineExercise.exerciseId,
            sets: performedSets,
          ),
        );
      }
    }
    return performed;
  }
}

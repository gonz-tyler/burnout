// lib/viewmodels/active_workout_view_model.dart

import 'package:flutter/material.dart';
import '../models/models.dart';

class ActiveWorkoutViewModel extends ChangeNotifier {
  Routine? _routine;
  bool _isWorkoutStarted = false;
  final List<RoutineExercise> _liveExercises = [];
  final Map<String, bool> _setCompletionStatus = {};

  // **NEW**: Map to track the weight mode for each exercise by its ID.
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
    _exerciseWeightModes.clear(); // Clear modes on new workout
    _isWorkoutStarted = true;
    notifyListeners();
  }

  String _getSetKey(int exerciseIndex, int setIndex) {
    final exerciseId = _liveExercises[exerciseIndex].exerciseId;
    return 'e${exerciseId}s$setIndex';
  }

  // **NEW**: Get the current weight mode for an exercise.
  WeightMode getWeightModeForExercise(Exercise exercise) {
    // If no mode is set, determine a sensible default.
    if (!_exerciseWeightModes.containsKey(exercise.id)) {
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

  // **NEW**: The logic to cycle through available weight modes.
  void cycleWeightModeForExercise(int exerciseIndex, Exercise exerciseDetails) {
    final modes = <WeightMode>[
      if (exerciseDetails.supportsWeight) WeightMode.weighted,
      if (exerciseDetails.supportsBodyweight) WeightMode.bodyweight,
      if (exerciseDetails.supportsAssistance) WeightMode.assisted,
    ];

    if (modes.length < 2) return; // No need to cycle if only one mode

    final currentMode = getWeightModeForExercise(exerciseDetails);
    final currentIndex = modes.indexOf(currentMode);
    final nextMode = modes[(currentIndex + 1) % modes.length];

    _exerciseWeightModes[exerciseDetails.id] = nextMode;

    // Update the weights of all sets for this exercise
    final routineExercise = _liveExercises[exerciseIndex];
    for (int i = 0; i < routineExercise.plannedSets.length; i++) {
      final currentSet = routineExercise.plannedSets[i];
      double newWeight;
      switch (nextMode) {
        case WeightMode.weighted:
          newWeight = currentSet.targetWeight?.abs() ?? 0.0;
          break;
        case WeightMode.bodyweight:
          newWeight = 0;
          break;
        case WeightMode.assisted:
          newWeight = -(currentSet.targetWeight?.abs() ?? 20.0);
          break;
      }
      _liveExercises[exerciseIndex].plannedSets[i] = currentSet.copyWith(
        targetWeight: newWeight,
      );
    }

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

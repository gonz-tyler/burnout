// lib/viewmodels/active_workout_view_model.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class ActiveWorkoutViewModel extends ChangeNotifier {
  late Routine _routine;
  late WorkoutSession _currentSession;
  bool _isWorkoutStarted = false;

  final List<RoutineExercise> _liveExercises = [];
  final Map<String, WeightMode> _exerciseWeightModes = {};
  final Map<int, List<PerformedSet>> _performedSetsData = {};
  final Map<int, List<bool>> _setCompletionStatus = {};

  bool _isNotifying = false;

  // --- GETTERS ---
  bool get isWorkoutStarted => _isWorkoutStarted;
  List<RoutineExercise> get liveExercises => _liveExercises;
  int get totalExercises => _liveExercises.length;

  int get completedExercisesCount {
    int count = 0;
    for (int i = 0; i < _liveExercises.length; i++) {
      final completionList = _setCompletionStatus[i] ?? [];
      bool allSetsCompleted =
          completionList.isNotEmpty &&
          completionList.every((isCompleted) => isCompleted);
      if (allSetsCompleted) count++;
    }
    return count;
  }

  void _debouncedNotifyListeners() {
    if (_isNotifying) return;
    _isNotifying = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isNotifying = false;
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  // --- ACTIONS ---
  void startWorkout(Routine routine) {
    _routine = routine;
    _liveExercises.clear();
    _liveExercises.addAll(routine.exercises.map((e) => e.copyWith()).toList());
    _performedSetsData.clear();
    _setCompletionStatus.clear();
    _exerciseWeightModes.clear();

    for (int i = 0; i < _liveExercises.length; i++) {
      final exercise = _liveExercises[i];
      final exerciseId = exercise.exerciseId;
      _exerciseWeightModes[exerciseId] = WeightMode.weighted;

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
      _setCompletionStatus[i] = List.generate(
        exercise.plannedSets.length,
        (_) => false,
      );
    }

    _currentSession = WorkoutSession(
      id: const Uuid().v4(),
      routineId: routine.id,
      dateCompleted: DateTime.now(),
      durationInMinutes: 0,
      performedExercises: [],
    );

    _isWorkoutStarted = true;
    notifyListeners();
  }

  WeightMode getWeightModeForExercise(int exerciseIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _liveExercises.length) {
      final exerciseId = _liveExercises[exerciseIndex].exerciseId;
      return _exerciseWeightModes[exerciseId] ?? WeightMode.weighted;
    }
    return WeightMode.weighted;
  }

  bool isSetCompleted(int exerciseIndex, int setIndex) {
    return _setCompletionStatus[exerciseIndex]?[setIndex] ?? false;
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex < _liveExercises.length) {
      _liveExercises[exerciseIndex].plannedSets.add(PlannedSet());
      _performedSetsData[exerciseIndex]?.add(
        PerformedSet(setType: SetType.normal, reps: 0, weight: 0),
      );
      _setCompletionStatus[exerciseIndex]?.add(false);
      _debouncedNotifyListeners();
    }
  }

  // **MODIFIED for AnimatedList**
  // Removes the data but doesn't notify, allowing the UI to animate the removal first.
  PlannedSet deleteSet(int exerciseIndex, int setIndex, {bool notify = true}) {
    final removedSet = _liveExercises[exerciseIndex].plannedSets.removeAt(
      setIndex,
    );
    _performedSetsData[exerciseIndex]?.removeAt(setIndex);
    _setCompletionStatus[exerciseIndex]?.removeAt(setIndex);

    if (notify) {
      _debouncedNotifyListeners();
    }
    return removedSet;
  }

  void updateSet(int exerciseIndex, int setIndex, PlannedSet updatedSet) {
    if (exerciseIndex < _liveExercises.length &&
        setIndex < _liveExercises[exerciseIndex].plannedSets.length) {
      _liveExercises[exerciseIndex].plannedSets[setIndex] = updatedSet;
      _debouncedNotifyListeners();
    }
  }

  void completeSet(int exerciseIndex, int setIndex) {
    if (_setCompletionStatus[exerciseIndex] != null &&
        _setCompletionStatus[exerciseIndex]!.length > setIndex) {
      _setCompletionStatus[exerciseIndex]![setIndex] =
          !_setCompletionStatus[exerciseIndex]![setIndex];
      _debouncedNotifyListeners();
    }
  }

  void cycleWeightModeForExercise(int exerciseIndex, Exercise exerciseDetails) {
    if (exerciseIndex >= _liveExercises.length) return;
    final exerciseId = _liveExercises[exerciseIndex].exerciseId;
    final modes = <WeightMode>[];
    if (exerciseDetails.supportsWeight) modes.add(WeightMode.weighted);
    if (exerciseDetails.supportsBodyweight) modes.add(WeightMode.bodyweight);
    if (exerciseDetails.supportsAssistance) modes.add(WeightMode.assisted);
    if (modes.length < 2) return;

    final currentMode = _exerciseWeightModes[exerciseId] ?? WeightMode.weighted;
    final currentIndex = modes.indexOf(currentMode);
    final nextMode = modes[(currentIndex + 1) % modes.length];
    _exerciseWeightModes[exerciseId] = nextMode;

    final routineExercise = _liveExercises[exerciseIndex];
    for (int i = 0; i < routineExercise.plannedSets.length; i++) {
      final currentSet = routineExercise.plannedSets[i];
      final currentWeight = currentSet.targetWeight ?? 0;
      double newWeight;
      switch (nextMode) {
        case WeightMode.weighted:
          newWeight = currentWeight.abs();
          break;
        case WeightMode.bodyweight:
          newWeight = 0;
          break;
        case WeightMode.assisted:
          newWeight = currentWeight == 0 ? -20.0 : -currentWeight.abs();
          break;
      }
      _liveExercises[exerciseIndex].plannedSets[i] = currentSet.copyWith(
        targetWeight: newWeight,
      );
    }
    _debouncedNotifyListeners();
  }

  void updateExerciseList(List<Exercise> selectedExercises) {
    final Map<String, RoutineExercise> existingExercisesMap = {
      for (var re in _liveExercises) re.exerciseId: re,
    };
    final List<RoutineExercise> updatedList = [];
    for (var exercise in selectedExercises) {
      if (existingExercisesMap.containsKey(exercise.id)) {
        updatedList.add(existingExercisesMap[exercise.id]!);
      } else {
        updatedList.add(
          RoutineExercise(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            plannedSets: [PlannedSet(setType: SetType.normal, targetReps: '')],
            restTimeInSeconds: 60,
          ),
        );
        _exerciseWeightModes[exercise.id] = WeightMode.weighted;
      }
    }
    _liveExercises.clear();
    _liveExercises.addAll(updatedList);
    _rebuildInternalDataMaps();
    notifyListeners();
  }

  void _rebuildInternalDataMaps() {
    final oldCompletionStatus = Map.from(_setCompletionStatus);
    final oldPerformedSets = Map.from(_performedSetsData);
    _setCompletionStatus.clear();
    _performedSetsData.clear();
    for (int i = 0; i < _liveExercises.length; i++) {
      final exercise = _liveExercises[i];
      // This logic can be simplified or improved, but for now, we'll re-initialize
      // to avoid complex index mapping issues.
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
      _setCompletionStatus[i] = List.generate(
        exercise.plannedSets.length,
        (_) => false,
      );
    }
  }
}

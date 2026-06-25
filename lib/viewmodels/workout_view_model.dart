// lib/viewmodels/workout_view_model.dart

import 'dart:math';
import 'package:burnout/models/battle_report_model.dart';
import 'package:flutter/material.dart';
import '../repositories/workout_repository.dart';
import '../services/streak_service.dart';
import '../models/models.dart';
import '../models/body_measurement.dart';

class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final StreakService _streakService;

  late List<Routine> _routines;
  late List<Exercise> _exercises;
  late List<WorkoutSession> _workoutSessions;

  // 🟢 NEW: Store measurements
  List<BodyMeasurement> _measurements = [];

  WorkoutViewModel({
    required WorkoutRepository workoutRepository,
    required StreakService streakService,
  }) : _workoutRepository = workoutRepository,
       _streakService = streakService {
    _loadData();
  }

  // --- Getters ---
  List<Routine> get routines => _routines;
  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get workoutSessions => _workoutSessions;
  List<BodyMeasurement> get measurements => _measurements;

  BodyMeasurement? get latestMeasurement =>
      _measurements.isNotEmpty ? _measurements.last : null;

  int get currentStreak => _streakService.calculateStreak(_workoutSessions);
  bool get didWorkoutToday => _streakService.didWorkoutToday(_workoutSessions);

  // 🟢 FUN METRIC: Total Volume (Tonnage)
  double get totalVolume {
    if (_workoutSessions.isEmpty) return 0;
    return _workoutSessions.fold(0, (total, session) {
      return total +
          session.performedExercises.fold(0, (exTotal, exercise) {
            return exTotal +
                exercise.sets.fold(0, (setTotal, set) {
                  return setTotal + ((set.weight ?? 0) * (set.reps ?? 0));
                });
          });
    });
  }

  void printMaxValues() {
    if (_measurements.isEmpty) {
      debugPrint("No measurements recorded yet.");
      return;
    }

    // Helper to find max of a specific field
    double? getMax(double? Function(BodyMeasurement) selector) {
      final values =
          _measurements
              .map(selector)
              .where((v) => v != null)
              .cast<double>(); // Filter out nulls

      if (values.isEmpty) return null;
      return values.reduce(max); // built-in dart:math function
    }

    debugPrint("\n📊 === ALL-TIME MAX STATS ===");
    debugPrint(
      "Weight:      ${getMax((m) => m.weightKg)?.toStringAsFixed(1) ?? '-'} kg",
    );
    debugPrint(
      "Body Fat:    ${getMax((m) => m.bodyFatPercentage)?.toStringAsFixed(1) ?? '-'} %",
    );
    debugPrint("--- TORSO ---");
    debugPrint(
      "Neck:        ${getMax((m) => m.neck)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "Shoulders:   ${getMax((m) => m.shoulders)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "Chest:       ${getMax((m) => m.chest)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "Waist:       ${getMax((m) => m.waist)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "Hips:        ${getMax((m) => m.hips)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint("--- ARMS ---");
    debugPrint(
      "L Bicep:     ${getMax((m) => m.leftBicep)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "R Bicep:     ${getMax((m) => m.rightBicep)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "L Forearm:   ${getMax((m) => m.leftForearm)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "R Forearm:   ${getMax((m) => m.rightForearm)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint("--- LEGS ---");
    debugPrint(
      "L Thigh:     ${getMax((m) => m.leftThigh)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "R Thigh:     ${getMax((m) => m.rightThigh)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "L Calf:      ${getMax((m) => m.leftCalf)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint(
      "R Calf:      ${getMax((m) => m.rightCalf)?.toStringAsFixed(1) ?? '-'} cm",
    );
    debugPrint("==============================\n");
  }

  void _loadData() {
    //_routines = _workoutRepository.getRoutines();
    _refreshRoutines();
    _exercises = _workoutRepository.getExercises();
    _workoutSessions = _workoutRepository.getWorkoutSessions();

    // Load measurements and sort them by date
    _measurements = _workoutRepository.getBodyMeasurements();
    _measurements.sort((a, b) => a.date.compareTo(b.date));

    notifyListeners();
  }

  // 🟢 UPDATE 2: Save to Repository
  void addMeasurement(BodyMeasurement measurement) {
    // 1. Save to Database
    _workoutRepository.addMeasurement(measurement);

    // 2. Update Local List & Sort
    _measurements.add(measurement);
    _measurements.sort((a, b) => a.date.compareTo(b.date));

    notifyListeners();
  }

  void _refreshRoutines() {
    _routines = _workoutRepository.getRoutines();

    // Sort by sortOrder (nulls go to the end)
    _routines.sort((a, b) {
      final aOrder = a.sortOrder ?? 999999;
      final bOrder = b.sortOrder ?? 999999;
      return aOrder.compareTo(bOrder);
    });

    notifyListeners();
  }

  void reorderRoutines(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final Routine item = _routines.removeAt(oldIndex);
    _routines.insert(newIndex, item);

    // 🟢 OPTIONAL: To persist this order permanently, you should add
    // an 'int? sortOrder' field to your Routine model.
    // Then loop through _routines and update their sortOrder:
    for (int i = 0; i < _routines.length; i++) {
      final updatedRoutine = _routines[i].copyWith(
        sortOrder: i,
      ); // You need to add sortOrder to Routine
      _workoutRepository.updateRoutine(updatedRoutine);
    }

    notifyListeners();
  }

  void updateRoutineWeights(String routineId, List<ExerciseResult> results) {
    try {
      // 1. Find the routine
      final routineIndex = _routines.indexWhere((r) => r.id == routineId);
      if (routineIndex == -1) return;

      final routine = _routines[routineIndex];

      // 2. Iterate through results and update matching exercises
      for (var result in results) {
        // Find the exercise in the routine (handle cases where it might appear twice)
        // We use 'where' in case the user has the same exercise multiple times
        final matchingExercises = routine.exercises.where(
          (e) => e.exerciseId == result.exerciseId,
        );

        for (var routineExercise in matchingExercises) {
          // 3. Update sets
          for (var i = 0; i < routineExercise.plannedSets.length; i++) {
            final set = routineExercise.plannedSets[i];

            // 🟢 CRITICAL: Only update Normal sets. Ignore Warmups/Dropsets.
            if (set.setType == SetType.normal) {
              // We create a new copy of the set with the new weight
              routineExercise.plannedSets[i] = set.copyWith(
                targetWeight: result.nextWeight,
              );
            }
          }
        }
      }

      // 4. Persist to Database
      _workoutRepository.updateRoutine(routine);

      // 5. Refresh local state
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating routine weights: $e");
    }
  }

  double _estimateOneRepMax(double weight, int reps) {
    if (reps <= 1) return weight; // 1 rep is just the weight itself
    return weight * (1 + (reps / 30.0));
  }

  // 🟢 UPDATED: Returns the highest ESTIMATED 1RM from history
  double getPersonalRecord(String exerciseNameQuery) {
    double max1RM = 0.0;

    // 1. Find all Exercise IDs matching the name
    final targetExerciseIds =
        _exercises
            .where(
              (e) => e.name.toLowerCase().contains(
                exerciseNameQuery.toLowerCase(),
              ),
            )
            .map((e) => e.id)
            .toSet();

    if (targetExerciseIds.isEmpty) return 0.0;

    // 2. Scan all history for the best set
    for (var session in _workoutSessions) {
      for (var performed in session.performedExercises) {
        if (targetExerciseIds.contains(performed.exerciseId)) {
          for (var set in performed.sets) {
            // Ensure we have valid data
            if (set.weight != null && set.weight! > 0) {
              final int reps =
                  (set.reps != null && set.reps! > 0) ? set.reps! : 1;

              // Calculate the 1RM for this specific set
              final double estimated1RM = _estimateOneRepMax(set.weight!, reps);

              // If this is the best set ever, save it
              if (estimated1RM > max1RM) {
                max1RM = estimated1RM;
              }
            }
          }
        }
      }
    }
    return max1RM;
  }

  // 🟢 FUN METRIC: Real world comparison
  String get volumeComparison {
    final kgs = totalVolume;
    if (kgs > 200000) return "Space Shuttle"; // ~200t
    if (kgs > 60000) return "M1 Abrams Tank"; // ~60t
    if (kgs > 5000) return "African Elephant"; // ~5t
    if (kgs > 1000) return "Saltwater Croc";
    return "Grand Piano";
  }

  // 🟢 AESTHETICS: Calculate Ideals based on Wrist Size (Steve Reeves formula)
  Map<String, double> getIdealProportions(double wristSizeCm) {
    var chestBase = wristSizeCm * 6.5;
    return {
      'Chest': chestBase,
      'Shoulders':
          chestBase * 1.1326, // Blended with the Golden Ratio (Waist * 1.618)
      'Hips': chestBase * 0.85,
      'Waist': chestBase * 0.70,
      'Thigh': chestBase * 0.53,
      'Neck': chestBase * 0.37,
      'Bicep': chestBase * 0.36,
      'Calf': chestBase * 0.34,
      'Forearm': chestBase * 0.29,
    };
  }

  // Helper to expose all sessions to the Service
  List<WorkoutSession> getAllWorkouts() => _workoutSessions;

  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((ex) => ex.id == id);
    } catch (e) {
      return null;
    }
  }

  // Pass-through methods
  // 🟢 FIX: Assign sortOrder to new routines
  void addRoutine(Routine routine) {
    // Put it at the end of the list
    final newRoutine = routine.copyWith(sortOrder: _routines.length);

    _workoutRepository.addRoutine(newRoutine);
    _refreshRoutines(); // Reload & Sort
  }

  void updateRoutine(Routine routine) {
    _workoutRepository.updateRoutine(routine);
    _refreshRoutines(); // Reload & Sort
  }

  void deleteRoutine(String routineId) {
    _workoutRepository.deleteRoutine(routineId);
    _refreshRoutines(); // Reload & Sort
  }

  void duplicateRoutine(String routineId) {
    _workoutRepository.duplicateRoutine(routineId);
    _refreshRoutines(); // Reload & Sort
  }

  void addWorkoutSession(WorkoutSession session) {
    _workoutRepository.addWorkoutSession(session);
    _workoutSessions = _workoutRepository.getWorkoutSessions();
    notifyListeners();
  }
}

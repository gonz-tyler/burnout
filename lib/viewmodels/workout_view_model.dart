// lib/viewmodels/workout_view_model.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../repositories/workout_repository.dart';
import '../services/streak_service.dart';
import '../models/models.dart';

class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final StreakService _streakService;

  late List<Routine> _routines;
  late List<Exercise> _exercises;
  late List<WorkoutSession> _workoutSessions;

  WorkoutViewModel({
    required WorkoutRepository workoutRepository,
    required StreakService streakService,
  }) : _workoutRepository = workoutRepository,
       _streakService = streakService {
    _loadData();
  }

  // --- Getters to expose data to the UI ---
  List<Routine> get routines => _routines;
  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get workoutSessions => _workoutSessions;

  // Getters for streak data
  int get currentStreak => _streakService.calculateStreak(_workoutSessions);
  bool get didWorkoutToday => _streakService.didWorkoutToday(_workoutSessions);

  // **NEW**: Getters for dashboard statistics
  double get totalVolume {
    if (_workoutSessions.isEmpty) return 0;
    return _workoutSessions.fold(0, (total, session) {
      return total +
          session.performedExercises.fold(0, (total, exercise) {
            return total +
                exercise.sets.fold(0, (total, set) {
                  return total + ((set.weight ?? 0) * (set.reps ?? 0));
                });
          });
    });
  }

  Map<int, int> get weeklyWorkoutCounts {
    final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    final today = DateTime.now();
    final sevenDaysAgo = today.subtract(const Duration(days: 6));

    for (var session in _workoutSessions) {
      if (session.dateCompleted.isAfter(sevenDaysAgo) ||
          DateUtils.isSameDay(session.dateCompleted, sevenDaysAgo)) {
        counts[session.dateCompleted.weekday] =
            (counts[session.dateCompleted.weekday] ?? 0) + 1;
      }
    }
    return counts;
  }

  // --- Private method to load all data from the repository ---
  void _loadData() {
    _routines = _workoutRepository.getRoutines();
    _exercises = _workoutRepository.getExercises();
    _workoutSessions = _workoutRepository.getWorkoutSessions();
  }

  // --- Helper Methods ---
  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((ex) => ex.id == id);
    } catch (e) {
      return null;
    }
  }

  // --- Methods to modify data and update the UI ---
  void addRoutine(Routine routine) {
    _workoutRepository.addRoutine(routine);
    _routines = _workoutRepository.getRoutines();
    notifyListeners();
  }

  void updateRoutine(Routine routine) {
    _workoutRepository.updateRoutine(routine);
    _routines = _workoutRepository.getRoutines();
    notifyListeners();
  }

  void deleteRoutine(String routineId) {
    _workoutRepository.deleteRoutine(routineId);
    _routines = _workoutRepository.getRoutines();
    notifyListeners();
  }

  void duplicateRoutine(String routineId) {
    _workoutRepository.duplicateRoutine(routineId);
    _routines = _workoutRepository.getRoutines();
    notifyListeners();
  }

  void addWorkoutSession(WorkoutSession session) {
    _workoutRepository.addWorkoutSession(session);
    _workoutSessions = _workoutRepository.getWorkoutSessions();
    notifyListeners();
  }

  int? get totalWorkouts {
    return _workoutSessions.length;
  }

  // Property: Best streak achieved
  int? get bestStreak {
    if (_workoutSessions.isEmpty) return 0;

    // Get unique workout dates and sort them
    final workoutDates =
        _workoutSessions
            .map(
              (session) => DateTime(
                session.dateCompleted.year,
                session.dateCompleted.month,
                session.dateCompleted.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();

    if (workoutDates.isEmpty) return 0;

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < workoutDates.length; i++) {
      final daysDifference =
          workoutDates[i].difference(workoutDates[i - 1]).inDays;

      if (daysDifference == 1) {
        currentStreak++;
      } else {
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        currentStreak = 1;
      }
    }

    return maxStreak > currentStreak ? maxStreak : currentStreak;
  }

  // Property: Workouts completed this week
  int? get weeklyWorkouts {
    if (_workoutSessions.isEmpty) return 0;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final startOfWeekDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeekDate = startOfWeekDate.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    return _workoutSessions.where((session) {
      return session.dateCompleted.isAfter(
            startOfWeekDate.subtract(const Duration(seconds: 1)),
          ) &&
          session.dateCompleted.isBefore(
            endOfWeekDate.add(const Duration(seconds: 1)),
          );
    }).length;
  }

  // Property: Workouts completed this month
  int? get monthlyWorkouts {
    if (_workoutSessions.isEmpty) return 0;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return _workoutSessions.where((session) {
      return session.dateCompleted.isAfter(
            startOfMonth.subtract(const Duration(seconds: 1)),
          ) &&
          session.dateCompleted.isBefore(
            endOfMonth.add(const Duration(seconds: 1)),
          );
    }).length;
  }

  // Method: Get workout count for specific day of current week
  int getWorkoutsForDay(int dayIndex) {
    if (_workoutSessions.isEmpty) return 0;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final targetDate = startOfWeek.add(Duration(days: dayIndex));
    final targetDateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    return _workoutSessions.where((session) {
      final sessionDateOnly = DateTime(
        session.dateCompleted.year,
        session.dateCompleted.month,
        session.dateCompleted.day,
      );
      return sessionDateOnly.isAtSameMomentAs(targetDateOnly);
    }).length;
  }
}

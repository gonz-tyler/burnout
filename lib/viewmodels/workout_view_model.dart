// lib/viewmodels/workout_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../repositories/workout_repository.dart';
import '../services/streak_service.dart';

class WorkoutViewModel extends ChangeNotifier {
  late final Box<Routine> routinesBox;
  final WorkoutRepository _workoutRepository;
  final StreakService _streakService;

  WorkoutViewModel({
    required WorkoutRepository workoutRepository,
    required StreakService streakService,
  }) : _workoutRepository = workoutRepository,
       _streakService = streakService {
    // --- ADD THIS ---
    print('✅ WorkoutViewModel CREATED! HashCode: ${this.hashCode}');
    // ---------------
    routinesBox = Hive.box<Routine>('routines');
    // _loadRoutines();
    // Load initial data when the view model is created
    loadData();
  }

  // --- Internal State ---
  List<Exercise> _exercises = [];
  List<WorkoutSession> _sessions = [];
  List<Routine> _routines = [];
  int _currentStreak = 0;
  bool _isLoading = false;

  // --- Getters for UI ---
  List<Exercise> get exercises => _exercises;
  List<Routine> get routines => _routines;
  int get currentStreak => _currentStreak;
  bool get isLoading => _isLoading;

  // --- Data Loading Method ---
  Future<void> loadData() async {
    _setLoading(true);

    // Load static exercises from JSON into Hive (if not already done)
    await _workoutRepository.loadExercisesFromJson();

    // Fetch data from repository
    _exercises = _workoutRepository.getAllExercises();
    _sessions = _workoutRepository.getAllWorkoutSessions();
    _routines = _workoutRepository.getAllRoutines();

    // Calculate business logic
    _calculateStreak();

    _setLoading(false);
  }

  // --- Business Logic Methods ---

  PerformedExercise? getPreviousPerformanceForExercise(String exerciseId) {
    return _workoutRepository.getPreviousPerformance(exerciseId);
  }

  /// Checks if the last workout session occurred today.
  bool get didWorkoutToday {
    if (_sessions.isEmpty) return false;

    final lastWorkoutDate = _sessions.last.dateCompleted;
    final now = DateTime.now();

    return now.day == lastWorkoutDate.day &&
        now.month == lastWorkoutDate.month &&
        now.year == lastWorkoutDate.year;
  }

  // --- Routine Management ---
  Future<void> addRoutine(Routine routine) async {
    await _workoutRepository.saveRoutine(routine);
    // Refresh routines list from repository
    _routines = _workoutRepository.getAllRoutines();
    notifyListeners();
  }

  /// Adds a new workout session and updates the streak.
  Future<void> addWorkoutSession(WorkoutSession session) async {
    // Save to database
    await _workoutRepository.saveWorkoutSession(session);

    // Refresh local state from database
    _sessions = _workoutRepository.getAllWorkoutSessions();

    // Recalculate streak
    _calculateStreak();

    // Notify UI to update
    notifyListeners();
  }

  void _calculateStreak() {
    // TODO: Get user's cadence goal from settings (e.g., 3 days)
    const int streakCadenceInDays = 3;

    _currentStreak = _streakService.calculateStreak(
      sessions: _sessions,
      streakCadenceInDays: streakCadenceInDays,
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // --- DELETE LOGIC ---
  void deleteRoutine(String routineId) {
    _routines.removeWhere((routine) => routine.id == routineId);
    routinesBox.delete(routineId);
    notifyListeners();
  }

  // --- EDIT/UPDATE LOGIC ---
  void updateRoutine(Routine updatedRoutine) {
    final index = _routines.indexWhere((r) => r.id == updatedRoutine.id);
    if (index != -1) {
      _routines[index] = updatedRoutine;
      routinesBox.put(updatedRoutine.id, updatedRoutine);
      notifyListeners();
    }
  }

  // --- DUPLICATE LOGIC ---
  void duplicateRoutine(String routineId) {
    final originalRoutine = _routines.firstWhere((r) => r.id == routineId);

    // 1. Find the base name (strip any existing " copy X" suffix)
    final baseName = originalRoutine.name.split(' copy ')[0];

    // 2. Find all other routines that are copies of this original
    final existingCopies = _routines.where(
      (r) => r.name.startsWith(baseName + ' copy '),
    );

    // 3. Find the next available copy number
    int nextCopyNumber = 1;
    if (existingCopies.isNotEmpty) {
      final copyNumbers =
          existingCopies.map((r) {
            final numPart = r.name.replaceFirst(baseName + ' copy ', '');
            return int.tryParse(numPart) ?? 0;
          }).toList();
      copyNumbers.sort();
      // Find the first missing number in the sequence (e.g., if we have 1 and 3, use 2)
      for (int i = 0; i < copyNumbers.length; i++) {
        if (copyNumbers[i] != i + 1) {
          nextCopyNumber = i + 1;
          break;
        }
        // If we get to the end, the next number is the highest + 1
        if (i == copyNumbers.length - 1) {
          nextCopyNumber = copyNumbers.length + 1;
        }
      }
    }

    // 4. Create the new duplicate object
    final newName = '$baseName copy $nextCopyNumber';
    final newRoutine = originalRoutine.copyWith(
      id: const Uuid().v4(), // Give it a new unique ID!
      name: newName,
    );

    // 5. Add it using your existing addRoutine method
    addRoutine(newRoutine);
  }
}

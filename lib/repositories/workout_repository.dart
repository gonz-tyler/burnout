// lib/repositories/workout_repository.dart

import 'package:burnout/models/models.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// Box names
const String exerciseBoxName = 'exercises';
const String routineBoxName = 'routines';
const String workoutSessionBoxName = 'workoutSessions';
const String planBoxName = 'workoutPlans';

class WorkoutRepository {
  late final Box<Exercise> _exerciseBox;
  late final Box<Routine> _routineBox;
  late final Box<WorkoutSession> _workoutSessionBox;
  late final Box<WorkoutPlan> _planBox;

  WorkoutRepository() {
    _exerciseBox = Hive.box<Exercise>(exerciseBoxName);
    _routineBox = Hive.box<Routine>(routineBoxName);
    _workoutSessionBox = Hive.box<WorkoutSession>(workoutSessionBoxName);
    _planBox = Hive.box<WorkoutPlan>(planBoxName);
  }

  // --- GETTERS ---
  List<Exercise> getExercises() {
    return _exerciseBox.values.toList();
  }

  List<Routine> getRoutines() {
    return _routineBox.values.toList();
  }

  List<WorkoutSession> getWorkoutSessions() {
    // Sort by date ascending to make sure the latest is always last
    final sessions = _workoutSessionBox.values.toList();
    sessions.sort((a, b) => a.dateCompleted.compareTo(b.dateCompleted));
    return sessions;
  }

  // --- WORKOUT SESSION METHODS ---
  Future<void> addWorkoutSession(WorkoutSession session) async {
    await _workoutSessionBox.put(session.id, session);
  }

  // --- ROUTINE METHODS ---
  Future<void> addRoutine(Routine routine) async {
    await _routineBox.put(routine.id, routine);
  }

  Future<void> updateRoutine(Routine routine) async {
    await _routineBox.put(routine.id, routine);
  }

  Future<void> deleteRoutine(String id) async {
    await _routineBox.delete(id);
  }

  Future<void> duplicateRoutine(String id) async {
    final original = _routineBox.get(id);
    if (original != null) {
      final newId = const Uuid().v4();
      final duplicatedRoutine = original.copyWith(
        id: newId,
        name: '${original.name} (Copy)',
      );
      await addRoutine(duplicatedRoutine);
    }
  }

  // --- EXERCISE METHODS ---
  Future<void> addExercises(List<Exercise> exercises) async {
    final Map<String, Exercise> exerciseMap = {
      for (var e in exercises) e.id: e,
    };
    await _exerciseBox.putAll(exerciseMap);
  }
}

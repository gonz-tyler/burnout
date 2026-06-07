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
  late final Box<Exercise> _exercisesBox;
  late final Box<Routine> _routinesBox;
  late final Box<WorkoutSession> _workoutSessionsBox;
  late final Box<WorkoutPlan> _planBox;
  late final Box<BodyMeasurement> _bodyMeasurementsBox;

  //WorkoutRepository() {
  //  _exerciseBox = Hive.box<Exercise>(exerciseBoxName);
  //  _routineBox = Hive.box<Routine>(routineBoxName);
  //  _workoutSessionBox = Hive.box<WorkoutSession>(workoutSessionBoxName);
  //  _planBox = Hive.box<WorkoutPlan>(planBoxName);
  //  _bodyMeasurementBox = Hive.box<BodyMeasurement>('bodyMeasurements');
  //}
  Future<void> init() async {
    _routinesBox = await Hive.openBox<Routine>('routines');
    _exercisesBox = await Hive.openBox<Exercise>('exercises');
    _workoutSessionsBox = await Hive.openBox<WorkoutSession>(
      'workout_sessions',
    );
    _bodyMeasurementsBox = await Hive.openBox<BodyMeasurement>(
      'body_measurements',
    );
  }

  // --- GETTERS ---
  List<Exercise> getExercises() {
    return _exercisesBox.values.toList();
  }

  List<Routine> getRoutines() {
    return _routinesBox.values.toList();
  }

  List<WorkoutSession> getWorkoutSessions() {
    // Sort by date ascending to make sure the latest is always last
    final sessions = _workoutSessionsBox.values.toList();
    sessions.sort((a, b) => a.dateCompleted.compareTo(b.dateCompleted));
    return sessions;
  }

  List<BodyMeasurement> getBodyMeasurements() {
    final measurements = _bodyMeasurementsBox.values.toList();
    measurements.sort((a, b) => a.date.compareTo(b.date));
    return measurements;
  }

  // --- BODY MEASUREMENT METHODS ---
  void addMeasurement(BodyMeasurement measurement) {
    _bodyMeasurementsBox.put(measurement.id, measurement);
  }

  void deleteMeasurement(String id) {
    _bodyMeasurementsBox.delete(id);
  }

  // --- WORKOUT SESSION METHODS ---
  Future<void> addWorkoutSession(WorkoutSession session) async {
    await _workoutSessionsBox.put(session.id, session);
  }

  // --- ROUTINE METHODS ---
  Future<void> addRoutine(Routine routine) async {
    await _routinesBox.put(routine.id, routine);
  }

  Future<void> updateRoutine(Routine routine) async {
    await _routinesBox.put(routine.id, routine);
  }

  Future<void> deleteRoutine(String id) async {
    await _routinesBox.delete(id);
  }

  Future<void> duplicateRoutine(String id) async {
    final original = _routinesBox.get(id);
    if (original != null) {
      final newId = const Uuid().v4();
      final duplicatedRoutine = original.copyWith(
        id: newId,
        name: '${original.name} (Copy)',
        sortOrder: _routinesBox.length,
      );
      await addRoutine(duplicatedRoutine);
    }
  }

  // --- EXERCISE METHODS ---
  Future<void> addExercises(List<Exercise> exercises) async {
    final Map<String, Exercise> exerciseMap = {
      for (var e in exercises) e.id: e,
    };
    await _exercisesBox.putAll(exerciseMap);
  }
}

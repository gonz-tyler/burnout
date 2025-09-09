// models/workout_session.dart
import 'package:burnout/models/exercise_in_workout.dart';

class WorkoutSession {
  final String id;
  final String workoutId;
  final String workoutName;
  final List<ExerciseInWorkout> exercises;
  final DateTime startedAt;
  final DateTime completedAt;
  final Duration? duration;
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.exercises,
    required this.startedAt,
    required this.completedAt,
    this.duration,
    this.notes,
  });

  Duration get actualDuration => duration ?? completedAt.difference(startedAt);

  int get completedSets => exercises.fold<int>(0, (sum, exercise) => 
    sum + exercise.sets.where((set) => set.isCompleted).length
  );

  int get totalSets => exercises.fold<int>(0, (sum, exercise) => 
    sum + exercise.sets.length
  );

  double get completionPercentage => totalSets > 0 ? (completedSets / totalSets) * 100 : 0;

  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    String? workoutName,
    List<ExerciseInWorkout>? exercises,
    DateTime? startedAt,
    DateTime? completedAt,
    Duration? duration,
    String? notes,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      exercises: exercises ?? this.exercises,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'workoutName': workoutName,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'duration': duration?.inSeconds,
      'notes': notes,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      workoutId: json['workoutId'],
      workoutName: json['workoutName'],
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseInWorkout.fromJson(e))
          .toList(),
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: DateTime.parse(json['completedAt']),
      duration: json['duration'] != null 
        ? Duration(seconds: json['duration']) 
        : null,
      notes: json['notes'],
    );
  }
}
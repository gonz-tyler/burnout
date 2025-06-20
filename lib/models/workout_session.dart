import 'package:burnout/models/exercise_in_workout.dart';
import 'package:flutter/material.dart';

class WorkoutSession {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final List<ExerciseInWorkout> exercises;
  final bool isCompleted;
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.exercises,
    this.isCompleted = false,
    this.notes,
  });

  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    String? workoutName,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    List<ExerciseInWorkout>? exercises,
    bool? isCompleted,
    String? notes,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
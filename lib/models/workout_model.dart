import 'package:burnout/models/exercise_in_workout.dart';
import 'package:flutter/material.dart';

class WorkoutModel {
  final String id;
  final String name;
  final String description;
  final List<ExerciseInWorkout> exercises;
  final DateTime? lastCompleted;
  final int totalSets;
  final String? notes;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.exercises,
    this.description = '',
    this.lastCompleted,
    this.notes,
  }) : totalSets = exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);

  WorkoutModel copyWith({
    String? id,
    String? name,
    String? description,
    List<ExerciseInWorkout>? exercises,
    DateTime? lastCompleted,
    String? notes,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      notes: notes ?? this.notes,
    );
  }
}
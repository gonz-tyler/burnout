// lib/models/routine.dart
import 'package:burnout/models/exercise.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'planned_set.dart';

part 'routine.g.dart'; // Add this line

@immutable
@HiveType(typeId: 2) // Assign unique typeId 2
class Routine {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<RoutineExercise> exercises; // Hive handles lists automatically

  const Routine({
    required this.id,
    required this.name,
    required this.exercises,
  });
  Routine copyWith({
    String? id,
    String? name,
    List<RoutineExercise>? exercises,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      // Create a deep copy of the exercises list
      exercises: exercises ?? this.exercises.map((e) => e.copyWith()).toList(),
    );
  }
}

@immutable
@HiveType(typeId: 3)
class RoutineExercise {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  final String exerciseName;

  @HiveField(2)
  final List<PlannedSet> plannedSets;

  @HiveField(3)
  final int restTimeInSeconds;

  // late final Exercise exercise;

  const RoutineExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.plannedSets,
    required this.restTimeInSeconds,
  });
  RoutineExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    List<PlannedSet>? plannedSets,
    int? restTimeInSeconds,
  }) {
    return RoutineExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      plannedSets: plannedSets ?? this.plannedSets,
      restTimeInSeconds: restTimeInSeconds ?? this.restTimeInSeconds,
    );
  }
}

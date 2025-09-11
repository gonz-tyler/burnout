// lib/models/workout_session.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'enums.dart';

part 'workout_session.g.dart'; // Add this line

@immutable
@HiveType(typeId: 5) // Assign unique typeId 5
class WorkoutSession {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? routineId;
  @HiveField(2)
  final DateTime dateCompleted;
  @HiveField(3)
  final int durationInMinutes;
  @HiveField(4)
  final List<PerformedExercise> performedExercises;
  @HiveField(5)
  final int? userFeedbackRPE;

  const WorkoutSession({
    required this.id,
    this.routineId,
    required this.dateCompleted,
    required this.durationInMinutes,
    required this.performedExercises,
    this.userFeedbackRPE,
  });
}

@immutable
@HiveType(typeId: 6) // Assign unique typeId 6 for nested class
class PerformedExercise {
  @HiveField(0)
  final String exerciseId;
  @HiveField(1)
  final List<PerformedSet> sets;

  const PerformedExercise({required this.exerciseId, required this.sets});
}

@immutable
@HiveType(typeId: 7) // Assign unique typeId 7 for nested class
class PerformedSet {
  @HiveField(0)
  final SetType setType;
  @HiveField(1)
  final int? reps;
  @HiveField(2)
  final double? weight;
  @HiveField(3)
  final int? durationInSeconds;
  @HiveField(4)
  final int? distanceInMeters;

  const PerformedSet({
    required this.setType,
    this.reps,
    this.weight,
    this.durationInSeconds,
    this.distanceInMeters,
  });
}

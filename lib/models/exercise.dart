// lib/models/exercise.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'exercise.g.dart'; // Add this line

@immutable
@HiveType(typeId: 1) // Assign unique typeId 1
class Exercise {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String muscleGroup;
  @HiveField(3)
  final String instructions;
  @HiveField(4)
  final String equipment;
  @HiveField(5)
  final Map<String, double> targetedMuscles;

  @HiveField(6)
  final bool tracksReps;
  @HiveField(7)
  final bool tracksDuration;
  @HiveField(8)
  final bool tracksDistance;

  @HiveField(9)
  final bool supportsWeight;
  @HiveField(10)
  final bool supportsBodyweight;
  @HiveField(11)
  final bool supportsAssistance;

  // ... constructor and fromJson methods remain unchanged ...
  // (Constructor parameters do not need annotations)
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.instructions,
    required this.equipment,
    required this.targetedMuscles,
    required this.tracksReps,
    required this.tracksDuration,
    required this.tracksDistance,
    required this.supportsWeight,
    required this.supportsBodyweight,
    required this.supportsAssistance,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      muscleGroup: json['muscleGroup'],
      instructions: json['instructions'] ?? '',
      equipment: json['equipment'] ?? '',
      targetedMuscles: Map<String, double>.from(json['targetedMuscles'] ?? {}),
      tracksReps: json['tracksReps'] ?? false,
      tracksDuration: json['tracksduration'] ?? json['tracksDuration'] ?? false,
      tracksDistance: json['tracksDistance'] ?? false,
      supportsWeight: json['supportsWeight'] ?? false,
      supportsBodyweight: json['supportsBodyweight'] ?? false,
      supportsAssistance: json['supportsAssistance'] ?? false,
    );
  }
}

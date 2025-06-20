import 'package:flutter/material.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup;
  final String? instructions;
  final Map<String, double>? targetedMuscles; // New: % activation per muscle
  final String exerciseType;
  final bool weightedSupport;
  final String? equipment;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.instructions,
    this.targetedMuscles,
    required this.exerciseType,
    this.weightedSupport = false,
    this.equipment,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      muscleGroup: json['muscleGroup'],
      instructions: json['instructions'],
      exerciseType: json['type'],
      weightedSupport: json['weightedSupport'],
      targetedMuscles: Map<String, double>.from(json['targetedMuscles']),
      equipment: json['equipment'],
    );
  }
}
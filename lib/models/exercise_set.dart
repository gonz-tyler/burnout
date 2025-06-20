

import 'package:burnout/models/set_type.dart';

class ExerciseSet {
  int setNumber;
  final SetType setType;
  
  // For weighted exercises
  final int? targetReps;
  final double? targetWeight;
  final int? actualReps;
  final double? actualWeight;
  
  // For duration exercises
  final Duration? targetDuration;
  final Duration? actualDuration;
  
  // For distance exercises
  final double? targetDistance;
  final double? actualDistance;

  // For assisted bodyweight or weighted bodyweight exercises
  final double? targetAssistedBodyweight; // Optional for bodyweight exercises
  final double? actualAssistedBodyweight; // Optional for bodyweight exercises

  final double? targetWeightedBodyweight; // Optional for weighted bodyweight exercises
  final double? actualWeightedBodyweight; // Optional for weighted bodyweight exercises
  
  final bool isCompleted;
  final String? notes;

  ExerciseSet({
    required this.setNumber,
    this.setType = SetType.normal,
    this.targetReps,
    this.targetWeight,
    this.actualReps,
    this.actualWeight,
    this.targetDuration,
    this.actualDuration,
    this.targetDistance,
    this.actualDistance,
    this.targetAssistedBodyweight,
    this.actualAssistedBodyweight,
    this.targetWeightedBodyweight,
    this.actualWeightedBodyweight,
    this.isCompleted = false,
    this.notes,
  });

  ExerciseSet copyWith({
    int? setNumber,
    SetType? setType,
    int? targetReps,
    double? targetWeight,
    int? actualReps,
    double? actualWeight,
    Duration? targetDuration,
    Duration? actualDuration,
    double? targetDistance,
    double? actualDistance,
    bool? isCompleted,
    String? notes,
  }) {
    return ExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      setType: setType ?? this.setType,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      actualReps: actualReps ?? this.actualReps,
      actualWeight: actualWeight ?? this.actualWeight,
      targetDuration: targetDuration ?? this.targetDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      targetDistance: targetDistance ?? this.targetDistance,
      actualDistance: actualDistance ?? this.actualDistance,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'setType': setType.index,
      'targetReps': targetReps,
      'targetWeight': targetWeight,
      'actualReps': actualReps,
      'actualWeight': actualWeight,
      'targetDuration': targetDuration?.inSeconds,
      'actualDuration': actualDuration?.inSeconds,
      'targetDistance': targetDistance,
      'actualDistance': actualDistance,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      setNumber: json['setNumber'],
      setType: SetType.values[json['setType'] ?? 0],
      targetReps: json['targetReps'],
      targetWeight: json['targetWeight']?.toDouble(),
      actualReps: json['actualReps'],
      actualWeight: json['actualWeight']?.toDouble(),
      targetDuration: json['targetDuration'] != null 
          ? Duration(seconds: json['targetDuration']) 
          : null,
      actualDuration: json['actualDuration'] != null 
          ? Duration(seconds: json['actualDuration']) 
          : null,
      targetDistance: json['targetDistance']?.toDouble(),
      actualDistance: json['actualDistance']?.toDouble(),
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
    );
  }
}
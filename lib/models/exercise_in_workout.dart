import 'package:burnout/models/exercise_set.dart';
import 'package:burnout/models/set_type.dart';

class ExerciseInWorkout {
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final String exerciseType; // Changed from ExerciseType enum to String
  final List<ExerciseSet> sets;
  final String? notes;

  const ExerciseInWorkout({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.exerciseType,
    required this.sets,
    this.notes,
  });

  // Helper getters - now checking string values instead of enum
  bool get isBodyweight => exerciseType == 'assistedbodyweight' || 
                          exerciseType == 'weightedbodyweight';
  
  bool get hasWeight => exerciseType == 'Weighted Reps' || 
                       exerciseType == 'assistedbodyweight' ||
                       exerciseType == 'weightedbodyweight' ||
                       exerciseType == 'weightdistance';
  
  bool get hasReps => exerciseType == 'Weighted Reps' || 
                     exerciseType == 'assistedbodyweight' ||
                     exerciseType == 'weightedbodyweight';
  
  bool get hasDuration => exerciseType == 'Duration' || 
                         exerciseType == 'durationdistance';
  
  bool get hasDistance => exerciseType == 'durationdistance' ||
                         exerciseType == 'weightdistance';

  int get normalSetCount {
    return sets.where((set) => set.setType == SetType.normal).length;
  }

  ExerciseInWorkout copyWith({
    String? exerciseId,
    String? exerciseName,
    String? muscleGroup,
    String? exerciseType, // Changed parameter type
    List<ExerciseSet>? sets,
    String? notes,
  }) {
    return ExerciseInWorkout(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      exerciseType: exerciseType ?? this.exerciseType,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup,
      'exerciseType': exerciseType, // No need for .index conversion
      'sets': sets.map((set) => set.toJson()).toList(),
      'notes': notes,
    };
  }

  factory ExerciseInWorkout.fromJson(Map<String, dynamic> json) {
    return ExerciseInWorkout(
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      muscleGroup: json['muscleGroup'],
      exerciseType: json['exerciseType'], // Direct string assignment
      sets: (json['sets'] as List)
          .map((setJson) => ExerciseSet.fromJson(setJson))
          .toList(),
      notes: json['notes'],
    );
  }
}
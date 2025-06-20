import 'package:burnout/models/exercise_in_workout.dart';
import 'package:burnout/models/exercise_model.dart';
import 'package:burnout/models/exercise_set.dart';
import 'package:burnout/models/workout_model.dart';
import 'package:flutter/material.dart';

class SampleData {
  static List<ExerciseModel> get exercises => [
  //   ExerciseModel(
  //     id: 'ab_wheel_rollout',
  //     name: 'Ab Wheel Rollout',
  //     muscleGroup: 'Core',
  //     category: 'Bodyweight',
  //     instructions: 'Kneel on the floor with the ab wheel in front of you. Grip the handles and roll the wheel forward, extending your body while keeping your core tight. Roll back to the starting position.',
  //     targetedMuscles: {
  //       'Abdominals': 0.6,
  //       'Obliques': 0.4,
  //     },
  //     type: 'Bodyweight Reps',
  //     weightedSupport: true
  //   ),
  //   ExerciseModel(
  //     id: 'abcoaster',
  //     name: 'Ab Coaster',
  //     muscleGroup: 'Core',
  //     category: 'Machine',
  //     instructions: 'Sit on the Ab Coaster with your feet on the footrests. Grip the handles and curl your hips up towards your chest, then lower back down.',
  //     targetedMuscles: {
  //       'Abdominals': 0.7,
  //       'Obliques': 0.3,
  //     },
  //     type: 'Bodyweight Reps',
  //     weightedSupport: true
  //   ),
  //   ExerciseModel(
  //     id: 'air_bike',
  //     name: 'Air Bike',
  //     muscleGroup: 'Cardio',
  //     category: 'Cardio',
  //     instructions: 'Sit on the air bike and pedal while simultaneously moving the handlebars. Engage your core throughout the movement.',
  //     targetedMuscles: {
  //       'Rectus Abdominis': 0.5,
  //       'Obliques': 0.3,
  //       'Hip Flexors': 0.2,
  //     },
  //     type: 'Duration',
  //     weightedSupport: false
  //   ),
  //   ExerciseModel(
  //     id: 'archer_pullups',
  //     name: 'Archer Pull Ups',
  //     muscleGroup: 'Back',
  //     category: 'Bodyweight',
  //     instructions: 'Hang from a pull-up bar with a wide grip. Pull your body up towards one hand while extending the other arm out to the side, then alternate sides.',
  //     targetedMuscles: {
  //       'Latissimus Dorsi': 0.5,
  //       'Biceps': 0.3,
  //       'Rhomboids': 0.2,
  //     },
  //     type: 'Bodyweight Reps',
  //     weightedSupport: true
  //   ),
  // ];

  // static List<WorkoutModel> get workouts => [
  //   WorkoutModel(
  //     id: 'full_body',
  //     name: 'Full Body',
  //     description: 'Complete full body workout',
  //     exercises: [
  //       ExerciseInWorkout(
  //         exerciseId: 'archer_pullups',
  //         exerciseName: 'Archer Pull Ups',
  //         muscleGroup: 'Back',
  //         isBodyweight: true,
  //         sets: [
  //           ExerciseSet(setNumber: 1, targetReps: 10),
  //           ExerciseSet(setNumber: 2, targetReps: 8),
  //           ExerciseSet(setNumber: 3, targetReps: 6),
  //           ExerciseSet(setNumber: 4, targetReps: 6),
  //         ],
  //       ),
  //       ExerciseInWorkout(
  //         exerciseId: 'deadlifts',
  //         exerciseName: 'Deadlifts (Barbell)',
  //         muscleGroup: 'Hamstrings',
  //         sets: [
  //           ExerciseSet(setNumber: 1, targetReps: 12, targetWeight: 60.0),
  //           ExerciseSet(setNumber: 2, targetReps: 12, targetWeight: 60.0),
  //           ExerciseSet(setNumber: 3, targetReps: 12, targetWeight: 60.0),
  //           ExerciseSet(setNumber: 4, targetReps: 12, targetWeight: 60.0),
  //         ],
  //       ),
  //       ExerciseInWorkout(
  //         exerciseId: 'bench_press',
  //         exerciseName: 'Bench Press (Barbell)',
  //         muscleGroup: 'Chest',
  //         sets: [
  //           ExerciseSet(setNumber: 1, targetReps: 10, targetWeight: 80.0),
  //           ExerciseSet(setNumber: 2, targetReps: 8, targetWeight: 85.0),
  //           ExerciseSet(setNumber: 3, targetReps: 6, targetWeight: 90.0),
  //         ],
  //       ),
  //     ],
  //     lastCompleted: DateTime.now().subtract(Duration(days: 2)),
  //   ),
  //   WorkoutModel(
  //     id: 'upper_body',
  //     name: 'Upper Body',
  //     description: 'Upper body focused workout',
  //     exercises: [
  //       ExerciseInWorkout(
  //         exerciseId: 'bench_press',
  //         exerciseName: 'Bench Press (Barbell)',
  //         muscleGroup: 'Chest',
  //         sets: [
  //           ExerciseSet(setNumber: 1, targetReps: 12, targetWeight: 70.0),
  //           ExerciseSet(setNumber: 2, targetReps: 10, targetWeight: 80.0),
  //           ExerciseSet(setNumber: 3, targetReps: 8, targetWeight: 85.0),
  //         ],
  //       ),
  //       ExerciseInWorkout(
  //         exerciseId: 'pullups',
  //         exerciseName: 'Pull Ups',
  //         muscleGroup: 'Back',
  //         isBodyweight: true,
  //         sets: [
  //           ExerciseSet(setNumber: 1, targetReps: 8),
  //           ExerciseSet(setNumber: 2, targetReps: 6),
  //           ExerciseSet(setNumber: 3, targetReps: 5),
  //         ],
  //       ),
  //     ],
  //   ),
  //   WorkoutModel(
  //     id: 'lower_body',
  //     name: 'Lower Body',
  //     description: 'Lower body focused workout',
  //     exercises: [
  //       ExerciseInWorkout(
  //         exerciseId: 'squats',
  //         exerciseName: 'Squats',
  //         muscleGroup: 'Quads',
  //         sets: [
  //           ExerciseSet(setNumber: 1, targetReps: 15, targetWeight: 60.0),
  //           ExerciseSet(setNumber: 2, targetReps: 12, targetWeight: 70.0),
  //           ExerciseSet(setNumber: 3, targetReps: 10, targetWeight: 80.0),
  //         ],
  //       ),
  //       ExerciseInWorkout(
  //         exerciseId: 'deadlifts',
  //         exerciseName: 'Deadlifts (Barbell)',
  //         muscleGroup: 'Hamstrings',
  //         sets: [
  //           ExerciseSet(setNumber: 1, targetReps: 10, targetWeight: 80.0),
  //           ExerciseSet(setNumber: 2, targetReps: 8, targetWeight: 90.0),
  //           ExerciseSet(setNumber: 3, targetReps: 6, targetWeight: 100.0),
  //         ],
  //       ),
  //     ],
  //   ),
  ];
}
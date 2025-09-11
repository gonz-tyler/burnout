// lib/models/workout_plan.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'workout_plan.g.dart'; // Add this line

@immutable
@HiveType(typeId: 4) // Assign unique typeId 4
class WorkoutPlan {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<String> routineIds;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.routineIds,
  });
}

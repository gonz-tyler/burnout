import 'package:hive/hive.dart';
import 'enums.dart';

part 'planned_set.g.dart';

@HiveType(typeId: 8) // Use a new, unique typeId
class PlannedSet {
  @HiveField(0)
  final SetType setType;

  @HiveField(1)
  final String? targetReps; // e.g., "5" or "8-12"

  @HiveField(2)
  final double? targetWeight; // Positive for weighted, negative for assisted

  @HiveField(3)
  final int? targetDurationInSeconds;

  @HiveField(4)
  final int? targetDistanceInMeters;

  PlannedSet({
    this.setType = SetType.normal,
    this.targetReps,
    this.targetWeight,
    this.targetDurationInSeconds,
    this.targetDistanceInMeters,
  });

  PlannedSet copyWith({
    SetType? setType,
    String? targetReps,
    double? targetWeight,
    int? targetDurationInSeconds,
    int? targetDistanceInMeters,
  }) {
    return PlannedSet(
      setType: setType ?? this.setType,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDurationInSeconds:
          targetDurationInSeconds ?? this.targetDurationInSeconds,
      targetDistanceInMeters:
          targetDistanceInMeters ?? this.targetDistanceInMeters,
    );
  }
}

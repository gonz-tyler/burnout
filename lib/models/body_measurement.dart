// lib/models/body_measurement.dart

import 'package:hive/hive.dart';

part 'body_measurement.g.dart';

@HiveType(typeId: 20) // Ensure this ID doesn't conflict with others
class BodyMeasurement {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final double? weightKg;
  @HiveField(3)
  final double? bodyFatPercentage;

  // Circumferences (in cm or inches, stored as double)
  @HiveField(4)
  final double? neck;
  @HiveField(5)
  final double? shoulders;
  @HiveField(6)
  final double? chest;
  @HiveField(7)
  final double? waist;
  @HiveField(8)
  final double? hips;
  @HiveField(9)
  final double? leftBicep;
  @HiveField(10)
  final double? rightBicep;
  @HiveField(11)
  final double? leftForearm;
  @HiveField(12)
  final double? rightForearm;
  @HiveField(13)
  final double? leftThigh;
  @HiveField(14)
  final double? rightThigh;
  @HiveField(15)
  final double? leftCalf;
  @HiveField(16)
  final double? rightCalf;

  // The "Anchor" for Golden Ratio calculations
  @HiveField(17)
  final double? wristSize;

  BodyMeasurement({
    required this.id,
    required this.date,
    this.weightKg,
    this.bodyFatPercentage,
    this.neck,
    this.shoulders,
    this.chest,
    this.waist,
    this.hips,
    this.leftBicep,
    this.rightBicep,
    this.leftForearm,
    this.rightForearm,
    this.leftThigh,
    this.rightThigh,
    this.leftCalf,
    this.rightCalf,
    this.wristSize,
  });

  // Helper to copy and update
  BodyMeasurement copyWith({
    double? weightKg,
    double? bodyFatPercentage,
    double? neck,
    double? shoulders,
    double? chest,
    double? waist,
    double? leftBicep,
    double? rightBicep,
    double? leftThigh,
    double? rightThigh,
    double? leftCalf,
    double? rightCalf,
    double? wristSize,
  }) {
    return BodyMeasurement(
      id: id,
      date: date,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      neck: neck ?? this.neck,
      shoulders: shoulders ?? this.shoulders,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      leftBicep: leftBicep ?? this.leftBicep,
      rightBicep: rightBicep ?? this.rightBicep,
      leftThigh: leftThigh ?? this.leftThigh,
      rightThigh: rightThigh ?? this.rightThigh,
      leftCalf: leftCalf ?? this.leftCalf,
      rightCalf: rightCalf ?? this.rightCalf,
      wristSize: wristSize ?? this.wristSize,
    );
  }
}

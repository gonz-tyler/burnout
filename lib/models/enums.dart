// lib/models/enums.dart
import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 0) // Assign unique typeId 0
enum SetType {
  @HiveField(0) // Start field index at 0
  warmup,

  @HiveField(1)
  normal,

  @HiveField(2)
  failure,

  @HiveField(3)
  dropset,
}

enum WeightMode { weighted, bodyweight, assisted }

extension SetTypeAbbreviation on SetType {
  String get abbreviation {
    switch (this) {
      case SetType.warmup:
        return 'W';
      case SetType.normal:
        return 'N';
      case SetType.failure:
        return 'F';
      case SetType.dropset:
        return 'D';
    }
  }
}

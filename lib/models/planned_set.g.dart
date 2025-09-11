// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_set.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlannedSetAdapter extends TypeAdapter<PlannedSet> {
  @override
  final int typeId = 8;

  @override
  PlannedSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannedSet(
      setType: fields[0] as SetType,
      targetReps: fields[1] as String?,
      targetWeight: fields[2] as double?,
      targetDurationInSeconds: fields[3] as int?,
      targetDistanceInMeters: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PlannedSet obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.setType)
      ..writeByte(1)
      ..write(obj.targetReps)
      ..writeByte(2)
      ..write(obj.targetWeight)
      ..writeByte(3)
      ..write(obj.targetDurationInSeconds)
      ..writeByte(4)
      ..write(obj.targetDistanceInMeters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 1;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      name: fields[1] as String,
      muscleGroup: fields[2] as String,
      instructions: fields[3] as String,
      equipment: fields[4] as String,
      targetedMuscles: (fields[5] as Map).cast<String, double>(),
      tracksReps: fields[6] as bool,
      tracksDuration: fields[7] as bool,
      tracksDistance: fields[8] as bool,
      supportsWeight: fields[9] as bool,
      supportsBodyweight: fields[10] as bool,
      supportsAssistance: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.muscleGroup)
      ..writeByte(3)
      ..write(obj.instructions)
      ..writeByte(4)
      ..write(obj.equipment)
      ..writeByte(5)
      ..write(obj.targetedMuscles)
      ..writeByte(6)
      ..write(obj.tracksReps)
      ..writeByte(7)
      ..write(obj.tracksDuration)
      ..writeByte(8)
      ..write(obj.tracksDistance)
      ..writeByte(9)
      ..write(obj.supportsWeight)
      ..writeByte(10)
      ..write(obj.supportsBodyweight)
      ..writeByte(11)
      ..write(obj.supportsAssistance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

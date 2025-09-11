// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 5;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSession(
      id: fields[0] as String,
      routineId: fields[1] as String?,
      dateCompleted: fields[2] as DateTime,
      durationInMinutes: fields[3] as int,
      performedExercises: (fields[4] as List).cast<PerformedExercise>(),
      userFeedbackRPE: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.routineId)
      ..writeByte(2)
      ..write(obj.dateCompleted)
      ..writeByte(3)
      ..write(obj.durationInMinutes)
      ..writeByte(4)
      ..write(obj.performedExercises)
      ..writeByte(5)
      ..write(obj.userFeedbackRPE);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PerformedExerciseAdapter extends TypeAdapter<PerformedExercise> {
  @override
  final int typeId = 6;

  @override
  PerformedExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PerformedExercise(
      exerciseId: fields[0] as String,
      sets: (fields[1] as List).cast<PerformedSet>(),
    );
  }

  @override
  void write(BinaryWriter writer, PerformedExercise obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.sets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformedExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PerformedSetAdapter extends TypeAdapter<PerformedSet> {
  @override
  final int typeId = 7;

  @override
  PerformedSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PerformedSet(
      setType: fields[0] as SetType,
      reps: fields[1] as int?,
      weight: fields[2] as double?,
      durationInSeconds: fields[3] as int?,
      distanceInMeters: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PerformedSet obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.setType)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.durationInSeconds)
      ..writeByte(4)
      ..write(obj.distanceInMeters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformedSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

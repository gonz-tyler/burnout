// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_measurement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyMeasurementAdapter extends TypeAdapter<BodyMeasurement> {
  @override
  final int typeId = 20;

  @override
  BodyMeasurement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyMeasurement(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      weightKg: fields[2] as double?,
      bodyFatPercentage: fields[3] as double?,
      neck: fields[4] as double?,
      shoulders: fields[5] as double?,
      chest: fields[6] as double?,
      waist: fields[7] as double?,
      hips: fields[8] as double?,
      leftBicep: fields[9] as double?,
      rightBicep: fields[10] as double?,
      leftForearm: fields[11] as double?,
      rightForearm: fields[12] as double?,
      leftThigh: fields[13] as double?,
      rightThigh: fields[14] as double?,
      leftCalf: fields[15] as double?,
      rightCalf: fields[16] as double?,
      wristSize: fields[17] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BodyMeasurement obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.bodyFatPercentage)
      ..writeByte(4)
      ..write(obj.neck)
      ..writeByte(5)
      ..write(obj.shoulders)
      ..writeByte(6)
      ..write(obj.chest)
      ..writeByte(7)
      ..write(obj.waist)
      ..writeByte(8)
      ..write(obj.hips)
      ..writeByte(9)
      ..write(obj.leftBicep)
      ..writeByte(10)
      ..write(obj.rightBicep)
      ..writeByte(11)
      ..write(obj.leftForearm)
      ..writeByte(12)
      ..write(obj.rightForearm)
      ..writeByte(13)
      ..write(obj.leftThigh)
      ..writeByte(14)
      ..write(obj.rightThigh)
      ..writeByte(15)
      ..write(obj.leftCalf)
      ..writeByte(16)
      ..write(obj.rightCalf)
      ..writeByte(17)
      ..write(obj.wristSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyMeasurementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

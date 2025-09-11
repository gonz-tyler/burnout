// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetTypeAdapter extends TypeAdapter<SetType> {
  @override
  final int typeId = 0;

  @override
  SetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SetType.warmup;
      case 1:
        return SetType.normal;
      case 2:
        return SetType.failure;
      case 3:
        return SetType.dropset;
      default:
        return SetType.warmup;
    }
  }

  @override
  void write(BinaryWriter writer, SetType obj) {
    switch (obj) {
      case SetType.warmup:
        writer.writeByte(0);
        break;
      case SetType.normal:
        writer.writeByte(1);
        break;
      case SetType.failure:
        writer.writeByte(2);
        break;
      case SetType.dropset:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

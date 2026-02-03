// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoseLogModelAdapter extends TypeAdapter<DoseLogModel> {
  @override
  final int typeId = 2;

  @override
  DoseLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseLogModel(
      logId: fields[0] as String,
      medId: fields[1] as String,
      scheduledTime: fields[2] as DateTime,
      actionTime: fields[3] as DateTime?,
      status: fields[4] as String,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DoseLogModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.logId)
      ..writeByte(1)
      ..write(obj.medId)
      ..writeByte(2)
      ..write(obj.scheduledTime)
      ..writeByte(3)
      ..write(obj.actionTime)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

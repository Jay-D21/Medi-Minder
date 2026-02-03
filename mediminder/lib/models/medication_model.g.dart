// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationModelAdapter extends TypeAdapter<MedicationModel> {
  @override
  final int typeId = 1;

  @override
  MedicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationModel(
      medId: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      dosage: fields[3] as double,
      dosageUnit: fields[4] as String,
      frequencyType: fields[5] as String,
      scheduleTimes: (fields[6] as List).cast<String>(),
      iconId: fields[7] as int,
      color: fields[8] as int,
      currentSupply: fields[9] as int,
      lowSupplyThreshold: fields[10] as int,
      isActive: fields[11] as bool,
      createdAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.medId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.dosage)
      ..writeByte(4)
      ..write(obj.dosageUnit)
      ..writeByte(5)
      ..write(obj.frequencyType)
      ..writeByte(6)
      ..write(obj.scheduleTimes)
      ..writeByte(7)
      ..write(obj.iconId)
      ..writeByte(8)
      ..write(obj.color)
      ..writeByte(9)
      ..write(obj.currentSupply)
      ..writeByte(10)
      ..write(obj.lowSupplyThreshold)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

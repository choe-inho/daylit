// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Quest_Model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestModelAdapter extends TypeAdapter<QuestModel> {
  @override
  final int typeId = 0;

  @override
  QuestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestModel(
      qid: fields[0] as String,
      uid: fields[1] as String,
      purpose: fields[2] as String,
      constraints: fields[3] as String,
      totalDays: fields[4] as int,
      totalCost: fields[5] as int,
      status: fields[6] as RoutineStatus,
      startDate: fields[7] as DateTime,
      endDate: fields[8] as DateTime,
      createdAt: fields[9] as DateTime,
      completedAt: fields[10] as DateTime?,
      aiRequestData: (fields[11] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.qid)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.purpose)
      ..writeByte(3)
      ..write(obj.constraints)
      ..writeByte(4)
      ..write(obj.totalDays)
      ..writeByte(5)
      ..write(obj.totalCost)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.aiRequestData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

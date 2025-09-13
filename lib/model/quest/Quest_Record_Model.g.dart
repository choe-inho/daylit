// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Quest_Record_Model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestRecordModelAdapter extends TypeAdapter<QuestRecordModel> {
  @override
  final int typeId = 4;

  @override
  QuestRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestRecordModel(
      qrid: fields[0] as String,
      qid: fields[1] as String,
      qdid: fields[2] as String,
      date: fields[3] as DateTime,
      status: fields[4] as RecordStatus,
      memo: fields[5] as String?,
      actualMinutes: fields[6] as int?,
      rating: fields[7] as int,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuestRecordModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.qrid)
      ..writeByte(1)
      ..write(obj.qid)
      ..writeByte(2)
      ..write(obj.qdid)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.memo)
      ..writeByte(6)
      ..write(obj.actualMinutes)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

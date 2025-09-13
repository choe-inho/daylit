// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Routine_Utils.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineStatusAdapter extends TypeAdapter<RoutineStatus> {
  @override
  final int typeId = 1;

  @override
  RoutineStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RoutineStatus.creating;
      case 1:
        return RoutineStatus.active;
      case 2:
        return RoutineStatus.paused;
      case 3:
        return RoutineStatus.completed;
      case 4:
        return RoutineStatus.failed;
      case 5:
        return RoutineStatus.cancelled;
      default:
        return RoutineStatus.creating;
    }
  }

  @override
  void write(BinaryWriter writer, RoutineStatus obj) {
    switch (obj) {
      case RoutineStatus.creating:
        writer.writeByte(0);
        break;
      case RoutineStatus.active:
        writer.writeByte(1);
        break;
      case RoutineStatus.paused:
        writer.writeByte(2);
        break;
      case RoutineStatus.completed:
        writer.writeByte(3);
        break;
      case RoutineStatus.failed:
        writer.writeByte(4);
        break;
      case RoutineStatus.cancelled:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecordStatusAdapter extends TypeAdapter<RecordStatus> {
  @override
  final int typeId = 2;

  @override
  RecordStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecordStatus.success;
      case 1:
        return RecordStatus.failed;
      case 2:
        return RecordStatus.skipped;
      case 3:
        return RecordStatus.partial;
      default:
        return RecordStatus.success;
    }
  }

  @override
  void write(BinaryWriter writer, RecordStatus obj) {
    switch (obj) {
      case RecordStatus.success:
        writer.writeByte(0);
        break;
      case RecordStatus.failed:
        writer.writeByte(1);
        break;
      case RecordStatus.skipped:
        writer.writeByte(2);
        break;
      case RecordStatus.partial:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MissionDifficultyAdapter extends TypeAdapter<MissionDifficulty> {
  @override
  final int typeId = 3;

  @override
  MissionDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MissionDifficulty.easy;
      case 1:
        return MissionDifficulty.medium;
      case 2:
        return MissionDifficulty.hard;
      default:
        return MissionDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, MissionDifficulty obj) {
    switch (obj) {
      case MissionDifficulty.easy:
        writer.writeByte(0);
        break;
      case MissionDifficulty.medium:
        writer.writeByte(1);
        break;
      case MissionDifficulty.hard:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

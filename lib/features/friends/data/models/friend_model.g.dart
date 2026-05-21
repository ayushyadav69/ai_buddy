// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendModelAdapter extends TypeAdapter<FriendModel> {
  @override
  final typeId = 1;

  @override
  FriendModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FriendModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      role: fields[3] as String,
      goal: fields[4] as String,
      personality: fields[5] as String,
      tone: fields[6] as String,
      responseStyle: fields[7] as String,
      boundaries: fields[8] as String,
      avatarType: fields[9] as String,
      voiceType: fields[10] as String,
      systemPrompt: fields[11] as String,
      syncStatus: fields[12] as SyncStatus,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      deletedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FriendModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.goal)
      ..writeByte(5)
      ..write(obj.personality)
      ..writeByte(6)
      ..write(obj.tone)
      ..writeByte(7)
      ..write(obj.responseStyle)
      ..writeByte(8)
      ..write(obj.boundaries)
      ..writeByte(9)
      ..write(obj.avatarType)
      ..writeByte(10)
      ..write(obj.voiceType)
      ..writeByte(11)
      ..write(obj.systemPrompt)
      ..writeByte(12)
      ..write(obj.syncStatus)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_memory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendMemoryModelAdapter extends TypeAdapter<FriendMemoryModel> {
  @override
  final typeId = 4;

  @override
  FriendMemoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FriendMemoryModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      friendId: fields[2] as String,
      text: fields[3] as String,
      categoryValue: fields[4] as String,
      importance: (fields[5] as num).toInt(),
      syncStatusValue: fields[6] as String,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      deletedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FriendMemoryModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.friendId)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.categoryValue)
      ..writeByte(5)
      ..write(obj.importance)
      ..writeByte(6)
      ..write(obj.syncStatusValue)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendMemoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

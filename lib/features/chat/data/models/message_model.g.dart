// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final typeId = 3;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      friendId: fields[2] as String,
      chatId: fields[3] as String,
      senderValue: fields[4] as String,
      text: fields[5] as String,
      audioLocalPath: fields[6] as String?,
      audioRemoteUrl: fields[7] as String?,
      attachmentId: fields[8] as String?,
      emotion: fields[9] as String?,
      statusValue: fields[10] as String,
      syncStatusValue: fields[11] as String,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      deletedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.friendId)
      ..writeByte(3)
      ..write(obj.chatId)
      ..writeByte(4)
      ..write(obj.senderValue)
      ..writeByte(5)
      ..write(obj.text)
      ..writeByte(6)
      ..write(obj.audioLocalPath)
      ..writeByte(7)
      ..write(obj.audioRemoteUrl)
      ..writeByte(8)
      ..write(obj.attachmentId)
      ..writeByte(9)
      ..write(obj.emotion)
      ..writeByte(10)
      ..write(obj.statusValue)
      ..writeByte(11)
      ..write(obj.syncStatusValue)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

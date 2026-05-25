// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatModelAdapter extends TypeAdapter<ChatModel> {
  @override
  final typeId = 2;

  @override
  ChatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      friendId: fields[2] as String,
      title: fields[3] as String,
      aiProviderValue: fields[4] as String,
      providerConversationId: fields[5] as String?,
      lastProviderResponseId: fields[6] as String?,
      providerCacheId: fields[7] as String?,
      localSummary: fields[8] as String?,
      summarizedTillMessageId: fields[9] as String?,
      lastMessage: fields[10] as String?,
      lastMessageAt: fields[11] as DateTime?,
      syncStatusValue: fields[12] as String,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      deletedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.friendId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.aiProviderValue)
      ..writeByte(5)
      ..write(obj.providerConversationId)
      ..writeByte(6)
      ..write(obj.lastProviderResponseId)
      ..writeByte(7)
      ..write(obj.providerCacheId)
      ..writeByte(8)
      ..write(obj.localSummary)
      ..writeByte(9)
      ..write(obj.summarizedTillMessageId)
      ..writeByte(10)
      ..write(obj.lastMessage)
      ..writeByte(11)
      ..write(obj.lastMessageAt)
      ..writeByte(12)
      ..write(obj.syncStatusValue)
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
      other is ChatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

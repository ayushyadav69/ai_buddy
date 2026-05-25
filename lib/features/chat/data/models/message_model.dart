import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_status.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'message_model.g.dart';

@HiveType(typeId: 3)
class MessageModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String friendId;

  @HiveField(3)
  final String chatId;

  @HiveField(4)
  final String senderValue;

  @HiveField(5)
  final String text;

  @HiveField(6)
  final String? audioLocalPath;

  @HiveField(7)
  final String? audioRemoteUrl;

  @HiveField(8)
  final String? attachmentId;

  @HiveField(9)
  final String? emotion;

  @HiveField(10)
  final String statusValue;

  @HiveField(11)
  final String syncStatusValue;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime updatedAt;

  @HiveField(14)
  final DateTime? deletedAt;

  const MessageModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.chatId,
    required this.senderValue,
    required this.text,
    this.audioLocalPath,
    this.audioRemoteUrl,
    this.attachmentId,
    this.emotion,
    required this.statusValue,
    required this.syncStatusValue,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  MessageSender get sender {
    return MessageSender.values.firstWhere(
      (sender) => sender.name == senderValue,
      orElse: () => MessageSender.system,
    );
  }

  MessageStatus get status {
    return MessageStatus.values.firstWhere(
      (status) => status.name == statusValue,
      orElse: () => MessageStatus.failed,
    );
  }

  SyncStatus get syncStatus {
    return SyncStatus.values.firstWhere(
      (status) => status.name == syncStatusValue,
      orElse: () => SyncStatus.failed,
    );
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      userId: entity.userId,
      friendId: entity.friendId,
      chatId: entity.chatId,
      senderValue: entity.sender.name,
      text: entity.text,
      audioLocalPath: entity.audioLocalPath,
      audioRemoteUrl: entity.audioRemoteUrl,
      attachmentId: entity.attachmentId,
      emotion: entity.emotion,
      statusValue: entity.status.name,
      syncStatusValue: entity.syncStatus.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      userId: userId,
      friendId: friendId,
      chatId: chatId,
      sender: sender,
      text: text,
      audioLocalPath: audioLocalPath,
      audioRemoteUrl: audioRemoteUrl,
      attachmentId: attachmentId,
      emotion: emotion,
      status: status,
      syncStatus: syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  MessageModel copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? chatId,
    MessageSender? sender,
    String? text,
    String? audioLocalPath,
    String? audioRemoteUrl,
    String? attachmentId,
    String? emotion,
    MessageStatus? status,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      chatId: chatId ?? this.chatId,
      senderValue: sender?.name ?? senderValue,
      text: text ?? this.text,
      audioLocalPath: audioLocalPath ?? this.audioLocalPath,
      audioRemoteUrl: audioRemoteUrl ?? this.audioRemoteUrl,
      attachmentId: attachmentId ?? this.attachmentId,
      emotion: emotion ?? this.emotion,
      statusValue: status?.name ?? statusValue,
      syncStatusValue: syncStatus?.name ?? syncStatusValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_status.dart';

class MessageEntity {
  final String id;
  final String userId;
  final String friendId;
  final String chatId;

  final MessageSender sender;
  final String text;

  final String? audioLocalPath;
  final String? audioRemoteUrl;

  final String? attachmentId;

  final String? emotion;

  final MessageStatus status;
  final SyncStatus syncStatus;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const MessageEntity({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.chatId,
    required this.sender,
    required this.text,
    this.audioLocalPath,
    this.audioRemoteUrl,
    this.attachmentId,
    this.emotion,
    required this.status,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isFromUser => sender == MessageSender.user;

  bool get isFromBuddy => sender == MessageSender.buddy;

  bool get isDeleted => deletedAt != null;
}

enum MessageSender { user, buddy, system }

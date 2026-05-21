import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/chat/domain/entities/ai_provider.dart';

class ChatEntity {
  final String id;
  final String userId;
  final String friendId;

  final String title;

  final AiProvider aiProvider;

  final String? providerConversationId;
  final String? lastProviderResponseId;
  final String? providerCacheId;

  final String? localSummary;
  final String? summarizedTillMessageId;

  final String? lastMessage;
  final DateTime? lastMessageAt;

  final SyncStatus syncStatus;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const ChatEntity({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.title,
    required this.aiProvider,
    this.providerConversationId,
    this.lastProviderResponseId,
    this.providerCacheId,
    this.localSummary,
    this.summarizedTillMessageId,
    this.lastMessage,
    this.lastMessageAt,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
}

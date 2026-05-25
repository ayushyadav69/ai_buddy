import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/chat/domain/entities/ai_provider.dart';
import 'package:ai_buddy/features/chat/domain/entities/chat_entity.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 2)
class ChatModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String friendId;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String aiProviderValue;

  @HiveField(5)
  final String? providerConversationId;

  @HiveField(6)
  final String? lastProviderResponseId;

  @HiveField(7)
  final String? providerCacheId;

  @HiveField(8)
  final String? localSummary;

  @HiveField(9)
  final String? summarizedTillMessageId;

  @HiveField(10)
  final String? lastMessage;

  @HiveField(11)
  final DateTime? lastMessageAt;

  @HiveField(12)
  final String syncStatusValue;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  @HiveField(15)
  final DateTime? deletedAt;

  const ChatModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.title,
    required this.aiProviderValue,
    this.providerConversationId,
    this.lastProviderResponseId,
    this.providerCacheId,
    this.localSummary,
    this.summarizedTillMessageId,
    this.lastMessage,
    this.lastMessageAt,
    required this.syncStatusValue,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  AiProvider get aiProvider {
    return AiProvider.values.firstWhere(
      (provider) => provider.name == aiProviderValue,
      orElse: () => AiProvider.gemini,
    );
  }

  SyncStatus get syncStatus {
    return SyncStatus.values.firstWhere(
      (status) => status.name == syncStatusValue,
      orElse: () => SyncStatus.failed,
    );
  }

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      id: entity.id,
      userId: entity.userId,
      friendId: entity.friendId,
      title: entity.title,
      aiProviderValue: entity.aiProvider.name,
      providerConversationId: entity.providerConversationId,
      lastProviderResponseId: entity.lastProviderResponseId,
      providerCacheId: entity.providerCacheId,
      localSummary: entity.localSummary,
      summarizedTillMessageId: entity.summarizedTillMessageId,
      lastMessage: entity.lastMessage,
      lastMessageAt: entity.lastMessageAt,
      syncStatusValue: entity.syncStatus.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  ChatEntity toEntity() {
    return ChatEntity(
      id: id,
      userId: userId,
      friendId: friendId,
      title: title,
      aiProvider: aiProvider,
      providerConversationId: providerConversationId,
      lastProviderResponseId: lastProviderResponseId,
      providerCacheId: providerCacheId,
      localSummary: localSummary,
      summarizedTillMessageId: summarizedTillMessageId,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      syncStatus: syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  ChatModel copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? title,
    AiProvider? aiProvider,
    String? providerConversationId,
    String? lastProviderResponseId,
    String? providerCacheId,
    String? localSummary,
    String? summarizedTillMessageId,
    String? lastMessage,
    DateTime? lastMessageAt,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      title: title ?? this.title,
      aiProviderValue: aiProvider?.name ?? aiProviderValue,
      providerConversationId:
          providerConversationId ?? this.providerConversationId,
      lastProviderResponseId:
          lastProviderResponseId ?? this.lastProviderResponseId,
      providerCacheId: providerCacheId ?? this.providerCacheId,
      localSummary: localSummary ?? this.localSummary,
      summarizedTillMessageId:
          summarizedTillMessageId ?? this.summarizedTillMessageId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      syncStatusValue: syncStatus?.name ?? syncStatusValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

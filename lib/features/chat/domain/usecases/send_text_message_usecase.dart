import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/ai/domain/repositories/ai_repository.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_status.dart';
import 'package:ai_buddy/features/chat/domain/repositories/chat_repository.dart';
import 'package:ai_buddy/features/friends/domain/repositories/friend_repository.dart';
import 'package:uuid/uuid.dart';

class SendTextMessageUseCase {
  final ChatRepository chatRepository;
  final FriendRepository friendRepository;
  final AiRepository aiRepository;
  final Uuid uuid;

  const SendTextMessageUseCase({
    required this.chatRepository,
    required this.friendRepository,
    required this.aiRepository,
    required this.uuid,
  });

  Future<MessageEntity> execute({
    required String userId,
    required String friendId,
    required String chatId,
    required String text,
  }) async {
    final trimmedText = text.trim();

    final now = DateTime.now();

    final userMessage = MessageEntity(
      id: uuid.v4(),
      userId: userId,
      friendId: friendId,
      chatId: chatId,
      sender: MessageSender.user,
      text: trimmedText,
      status: MessageStatus.sent,
      syncStatus: SyncStatus.pendingCreate,
      createdAt: now,
      updatedAt: now,
    );

    await chatRepository.saveMessage(userMessage);

    final friend = await friendRepository.getFriendById(friendId: friendId);

    if (friend == null) {
      throw Exception('Friend not found.');
    }

    final recentMessages = await chatRepository.getMessages(chatId: chatId);

    final aiReply = await aiRepository.generateReply(
      systemPrompt: friend.systemPrompt,
      recentMessages: recentMessages,
      currentMessage: trimmedText,
    );

    final replyTime = DateTime.now();

    final buddyMessage = MessageEntity(
      id: uuid.v4(),
      userId: userId,
      friendId: friendId,
      chatId: chatId,
      sender: MessageSender.buddy,
      text: aiReply.reply,
      emotion: aiReply.emotion,
      status: MessageStatus.sent,
      syncStatus: SyncStatus.pendingCreate,
      createdAt: replyTime,
      updatedAt: replyTime,
    );

    await chatRepository.saveMessage(buddyMessage);

    return buddyMessage;
  }
}

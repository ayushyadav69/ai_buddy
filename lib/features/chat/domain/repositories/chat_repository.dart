import 'package:ai_buddy/features/chat/domain/entities/chat_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<ChatEntity?> getChatByFriendId({
    required String userId,
    required String friendId,
  });

  Future<void> createChat(ChatEntity chat);

  Future<List<MessageEntity>> getMessages({required String chatId});

  Future<void> saveMessage(MessageEntity message);
}

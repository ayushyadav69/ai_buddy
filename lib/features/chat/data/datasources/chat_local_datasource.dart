import 'package:ai_buddy/features/chat/data/models/chat_model.dart';
import 'package:ai_buddy/features/chat/data/models/message_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

abstract class ChatLocalDataSource {
  Future<ChatModel?> getChatByFriendId({
    required String userId,
    required String friendId,
  });

  Future<void> createChat(ChatModel chat);

  Future<List<MessageModel>> getMessages({required String chatId});

  Future<void> saveMessage(MessageModel message);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Box<ChatModel> chatBox;
  final Box<MessageModel> messageBox;

  const ChatLocalDataSourceImpl({
    required this.chatBox,
    required this.messageBox,
  });

  @override
  Future<ChatModel?> getChatByFriendId({
    required String userId,
    required String friendId,
  }) async {
    for (final chat in chatBox.values) {
      final isMatchingChat =
          chat.userId == userId &&
          chat.friendId == friendId &&
          chat.deletedAt == null;

      if (isMatchingChat) {
        return chat;
      }
    }

    return null;
  }

  @override
  Future<void> createChat(ChatModel chat) async {
    await chatBox.put(chat.id, chat);
  }

  @override
  Future<List<MessageModel>> getMessages({required String chatId}) async {
    return messageBox.values
        .where(
          (message) => message.chatId == chatId && message.deletedAt == null,
        )
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<void> saveMessage(MessageModel message) async {
    await messageBox.put(message.id, message);

    final chat = chatBox.get(message.chatId);

    if (chat == null) {
      return;
    }

    final updatedChat = chat.copyWith(
      lastMessage: message.text,
      lastMessageAt: message.createdAt,
      updatedAt: DateTime.now(),
    );

    await chatBox.put(chat.id, updatedChat);
  }
}

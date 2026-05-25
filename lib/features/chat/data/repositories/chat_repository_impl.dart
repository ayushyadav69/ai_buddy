import 'package:ai_buddy/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:ai_buddy/features/chat/data/models/chat_model.dart';
import 'package:ai_buddy/features/chat/data/models/message_model.dart';
import 'package:ai_buddy/features/chat/domain/entities/chat_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;

  const ChatRepositoryImpl({required this.localDataSource});

  @override
  Future<ChatEntity?> getChatByFriendId({
    required String userId,
    required String friendId,
  }) async {
    final chat = await localDataSource.getChatByFriendId(
      userId: userId,
      friendId: friendId,
    );

    return chat?.toEntity();
  }

  @override
  Future<void> createChat(ChatEntity chat) {
    final model = ChatModel.fromEntity(chat);

    return localDataSource.createChat(model);
  }

  @override
  Future<List<MessageEntity>> getMessages({required String chatId}) async {
    final messages = await localDataSource.getMessages(chatId: chatId);

    return messages.map((message) => message.toEntity()).toList();
  }

  @override
  Future<void> saveMessage(MessageEntity message) {
    final model = MessageModel.fromEntity(message);

    return localDataSource.saveMessage(model);
  }
}

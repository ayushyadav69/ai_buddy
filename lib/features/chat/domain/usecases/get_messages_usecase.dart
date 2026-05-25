import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  const GetMessagesUseCase(this.repository);

  Future<List<MessageEntity>> execute({required String chatId}) {
    return repository.getMessages(chatId: chatId);
  }
}

import 'package:ai_buddy/features/chat/domain/entities/chat_entity.dart';
import 'package:ai_buddy/features/chat/domain/repositories/chat_repository.dart';

class CreateChatUseCase {
  final ChatRepository repository;

  const CreateChatUseCase(this.repository);

  Future<void> execute(ChatEntity chat) {
    return repository.createChat(chat);
  }
}

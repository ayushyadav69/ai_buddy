import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/domain/repositories/chat_repository.dart';

class SaveMessageUseCase {
  final ChatRepository repository;

  const SaveMessageUseCase(this.repository);

  Future<void> execute(MessageEntity message) {
    return repository.saveMessage(message);
  }
}

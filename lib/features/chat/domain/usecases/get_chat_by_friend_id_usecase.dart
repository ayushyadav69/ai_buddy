import 'package:ai_buddy/features/chat/domain/entities/chat_entity.dart';
import 'package:ai_buddy/features/chat/domain/repositories/chat_repository.dart';

class GetChatByFriendIdUseCase {
  final ChatRepository repository;

  const GetChatByFriendIdUseCase(this.repository);

  Future<ChatEntity?> execute({
    required String userId,
    required String friendId,
  }) {
    return repository.getChatByFriendId(userId: userId, friendId: friendId);
  }
}

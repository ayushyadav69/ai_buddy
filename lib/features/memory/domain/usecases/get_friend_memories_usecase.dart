import 'package:ai_buddy/features/memory/domain/entities/friend_memory_entity.dart';
import 'package:ai_buddy/features/memory/domain/repositories/memory_repository.dart';

class GetFriendMemoriesUseCase {
  final MemoryRepository repository;

  const GetFriendMemoriesUseCase(this.repository);

  Future<List<FriendMemoryEntity>> execute({required String friendId}) {
    return repository.getMemories(friendId: friendId);
  }
}

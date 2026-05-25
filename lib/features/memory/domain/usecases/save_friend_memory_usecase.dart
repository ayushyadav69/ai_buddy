import 'package:ai_buddy/features/memory/domain/entities/friend_memory_entity.dart';
import 'package:ai_buddy/features/memory/domain/repositories/memory_repository.dart';

class SaveFriendMemoryUseCase {
  final MemoryRepository repository;

  const SaveFriendMemoryUseCase(this.repository);

  Future<void> execute(FriendMemoryEntity memory) {
    return repository.saveMemory(memory);
  }
}

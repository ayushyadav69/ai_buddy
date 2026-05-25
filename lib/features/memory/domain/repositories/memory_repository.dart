import 'package:ai_buddy/features/memory/domain/entities/friend_memory_entity.dart';

abstract class MemoryRepository {
  Future<List<FriendMemoryEntity>> getMemories({required String friendId});

  Future<void> saveMemory(FriendMemoryEntity memory);

  Future<void> deleteMemory({required String memoryId});
}

import 'package:ai_buddy/features/memory/data/datasources/memory_local_datasource.dart';
import 'package:ai_buddy/features/memory/data/models/friend_memory_model.dart';
import 'package:ai_buddy/features/memory/domain/entities/friend_memory_entity.dart';
import 'package:ai_buddy/features/memory/domain/repositories/memory_repository.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  final MemoryLocalDataSource localDataSource;

  const MemoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<FriendMemoryEntity>> getMemories({
    required String friendId,
  }) async {
    final memories = await localDataSource.getMemories(friendId: friendId);

    return memories.map((memory) => memory.toEntity()).toList();
  }

  @override
  Future<void> saveMemory(FriendMemoryEntity memory) {
    final model = FriendMemoryModel.fromEntity(memory);

    return localDataSource.saveMemory(model);
  }

  @override
  Future<void> deleteMemory({required String memoryId}) {
    return localDataSource.deleteMemory(memoryId: memoryId);
  }
}

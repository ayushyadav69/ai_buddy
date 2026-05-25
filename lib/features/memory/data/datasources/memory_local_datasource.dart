import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/memory/data/models/friend_memory_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

abstract class MemoryLocalDataSource {
  Future<List<FriendMemoryModel>> getMemories({required String friendId});

  Future<void> saveMemory(FriendMemoryModel memory);

  Future<void> deleteMemory({required String memoryId});
}

class MemoryLocalDataSourceImpl implements MemoryLocalDataSource {
  final Box<FriendMemoryModel> memoryBox;

  const MemoryLocalDataSourceImpl({required this.memoryBox});

  @override
  Future<List<FriendMemoryModel>> getMemories({
    required String friendId,
  }) async {
    return memoryBox.values
        .where(
          (memory) => memory.friendId == friendId && memory.deletedAt == null,
        )
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));
  }

  @override
  Future<void> saveMemory(FriendMemoryModel memory) async {
    await memoryBox.put(memory.id, memory);
  }

  @override
  Future<void> deleteMemory({required String memoryId}) async {
    final memory = memoryBox.get(memoryId);

    if (memory == null) {
      return;
    }

    final deletedMemory = memory.copyWith(
      syncStatus: SyncStatus.pendingDelete,
      updatedAt: DateTime.now(),
      deletedAt: DateTime.now(),
    );

    await memoryBox.put(memoryId, deletedMemory);
  }
}

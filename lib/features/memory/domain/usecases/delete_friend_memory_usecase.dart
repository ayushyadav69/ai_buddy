import 'package:ai_buddy/features/memory/domain/repositories/memory_repository.dart';

class DeleteFriendMemoryUseCase {
  final MemoryRepository repository;

  const DeleteFriendMemoryUseCase(this.repository);

  Future<void> execute({required String memoryId}) {
    return repository.deleteMemory(memoryId: memoryId);
  }
}

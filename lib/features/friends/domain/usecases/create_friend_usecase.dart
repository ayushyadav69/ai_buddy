import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';
import 'package:ai_buddy/features/friends/domain/repositories/friend_repository.dart';

class CreateFriendUseCase {
  final FriendRepository repository;

  const CreateFriendUseCase(this.repository);

  Future<void> execute(FriendEntity friend) {
    return repository.createFriend(friend);
  }
}

import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';
import 'package:ai_buddy/features/friends/domain/repositories/friend_repository.dart';

class UpdateFriendUseCase {
  final FriendRepository repository;

  const UpdateFriendUseCase(this.repository);

  Future<void> execute(FriendEntity friend) {
    return repository.updateFriend(friend);
  }
}

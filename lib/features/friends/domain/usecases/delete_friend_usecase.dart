import 'package:ai_buddy/features/friends/domain/repositories/friend_repository.dart';

class DeleteFriendUseCase {
  final FriendRepository repository;

  const DeleteFriendUseCase(this.repository);

  Future<void> execute({required String friendId}) {
    return repository.deleteFriend(friendId: friendId);
  }
}

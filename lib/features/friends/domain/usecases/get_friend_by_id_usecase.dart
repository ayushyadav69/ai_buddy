import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';
import 'package:ai_buddy/features/friends/domain/repositories/friend_repository.dart';

class GetFriendByIdUseCase {
  final FriendRepository repository;

  const GetFriendByIdUseCase(this.repository);

  Future<FriendEntity?> execute({required String friendId}) {
    return repository.getFriendById(friendId: friendId);
  }
}

import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';
import 'package:ai_buddy/features/friends/domain/repositories/friend_repository.dart';

class GetFriendsUseCase {
  final FriendRepository repository;

  const GetFriendsUseCase(this.repository);

  Future<List<FriendEntity>> execute({required String userId}) {
    return repository.getFriends(userId: userId);
  }
}

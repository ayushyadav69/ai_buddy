import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';

abstract class FriendRepository {
  Future<List<FriendEntity>> getFriends({required String userId});

  Future<FriendEntity?> getFriendById({required String friendId});

  Future<void> createFriend(FriendEntity friend);

  Future<void> updateFriend(FriendEntity friend);

  Future<void> deleteFriend({required String friendId});
}

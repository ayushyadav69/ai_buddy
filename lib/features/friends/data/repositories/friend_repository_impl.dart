import 'package:ai_buddy/features/friends/data/datasources/friend_local_datasource.dart';
import 'package:ai_buddy/features/friends/data/models/friend_model.dart';
import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';
import 'package:ai_buddy/features/friends/domain/repositories/friend_repository.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendLocalDataSource localDataSource;

  const FriendRepositoryImpl({required this.localDataSource});

  @override
  Future<List<FriendEntity>> getFriends({required String userId}) async {
    final friends = await localDataSource.getFriends(userId: userId);

    return friends.map((friend) => friend.toEntity()).toList();
  }

  @override
  Future<FriendEntity?> getFriendById({required String friendId}) async {
    final friend = await localDataSource.getFriendById(friendId: friendId);

    return friend?.toEntity();
  }

  @override
  Future<void> createFriend(FriendEntity friend) {
    final model = FriendModel.fromEntity(friend);

    return localDataSource.saveFriend(model);
  }

  @override
  Future<void> updateFriend(FriendEntity friend) {
    final model = FriendModel.fromEntity(friend);

    return localDataSource.updateFriend(model);
  }

  @override
  Future<void> deleteFriend({required String friendId}) {
    return localDataSource.deleteFriend(friendId: friendId);
  }
}

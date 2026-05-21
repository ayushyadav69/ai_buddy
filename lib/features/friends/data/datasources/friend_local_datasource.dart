import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/friends/data/models/friend_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

abstract class FriendLocalDataSource {
  Future<List<FriendModel>> getFriends({required String userId});

  Future<FriendModel?> getFriendById({required String friendId});

  Future<void> saveFriend(FriendModel friend);

  Future<void> updateFriend(FriendModel friend);

  Future<void> deleteFriend({required String friendId});
}

class FriendLocalDataSourceImpl implements FriendLocalDataSource {
  final Box<FriendModel> friendBox;

  const FriendLocalDataSourceImpl({required this.friendBox});

  @override
  Future<List<FriendModel>> getFriends({required String userId}) async {
    return friendBox.values
        .where((friend) => friend.userId == userId && friend.deletedAt == null)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<FriendModel?> getFriendById({required String friendId}) async {
    final friend = friendBox.get(friendId);

    if (friend == null || friend.deletedAt != null) {
      return null;
    }

    return friend;
  }

  @override
  Future<void> saveFriend(FriendModel friend) async {
    await friendBox.put(friend.id, friend);
  }

  @override
  Future<void> updateFriend(FriendModel friend) async {
    await friendBox.put(friend.id, friend);
  }

  @override
  Future<void> deleteFriend({required String friendId}) async {
    final friend = friendBox.get(friendId);

    if (friend == null) {
      return;
    }

    final deletedFriend = friend.copyWith(
      syncStatus: SyncStatus.pendingDelete,
      updatedAt: DateTime.now(),
      deletedAt: DateTime.now(),
    );

    await friendBox.put(friendId, deletedFriend);
  }
}

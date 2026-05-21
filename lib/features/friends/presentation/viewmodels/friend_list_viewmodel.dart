import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';
import 'package:ai_buddy/features/friends/presentation/providers/friend_dependency_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendListState {
  final bool isLoading;
  final List<FriendEntity> friends;
  final String? errorMessage;

  const FriendListState({
    this.isLoading = false,
    this.friends = const [],
    this.errorMessage,
  });

  FriendListState copyWith({
    bool? isLoading,
    List<FriendEntity>? friends,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FriendListState(
      isLoading: isLoading ?? this.isLoading,
      friends: friends ?? this.friends,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class FriendListViewModel extends Notifier<FriendListState> {
  @override
  FriendListState build() {
    return const FriendListState();
  }

  Future<void> loadFriends({required String userId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final getFriendsUseCase = ref.read(getFriendsUseCaseProvider);

      final friends = await getFriendsUseCase.execute(userId: userId);

      state = state.copyWith(isLoading: false, friends: friends);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}

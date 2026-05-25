import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';
import 'package:ai_buddy/features/friends/presentation/providers/friend_dependency_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendProfileState {
  final bool isLoading;
  final bool isDeleting;
  final FriendEntity? friend;
  final String? errorMessage;
  final bool isDeleted;

  const FriendProfileState({
    this.isLoading = false,
    this.isDeleting = false,
    this.friend,
    this.errorMessage,
    this.isDeleted = false,
  });

  FriendProfileState copyWith({
    bool? isLoading,
    bool? isDeleting,
    FriendEntity? friend,
    String? errorMessage,
    bool? isDeleted,
    bool clearError = false,
  }) {
    return FriendProfileState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      friend: friend ?? this.friend,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class FriendProfileViewModel extends Notifier<FriendProfileState> {
  @override
  FriendProfileState build() {
    return const FriendProfileState();
  }

  Future<void> loadFriend({required String friendId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final getFriendByIdUseCase = ref.read(getFriendByIdUseCaseProvider);

      final friend = await getFriendByIdUseCase.execute(friendId: friendId);

      state = state.copyWith(isLoading: false, friend: friend);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> deleteFriend({required String friendId}) async {
    state = state.copyWith(isDeleting: true, clearError: true);

    try {
      final deleteFriendUseCase = ref.read(deleteFriendUseCaseProvider);

      await deleteFriendUseCase.execute(friendId: friendId);

      state = state.copyWith(isDeleting: false, isDeleted: true);
    } catch (error) {
      state = state.copyWith(isDeleting: false, errorMessage: error.toString());
    }
  }
}

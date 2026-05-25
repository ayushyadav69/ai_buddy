import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';
import 'package:ai_buddy/features/friends/presentation/providers/friend_dependency_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_buddy/core/providers/core_providers.dart';

class FriendFormState {
  final bool isLoading;
  final String? errorMessage;
  final FriendEntity? savedFriend;

  const FriendFormState({
    this.isLoading = false,
    this.errorMessage,
    this.savedFriend,
  });

  FriendFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    FriendEntity? savedFriend,
    bool clearError = false,
    bool clearSavedFriend = false,
  }) {
    return FriendFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      savedFriend: clearSavedFriend ? null : savedFriend ?? this.savedFriend,
    );
  }
}

class FriendFormViewModel extends Notifier<FriendFormState> {
  @override
  FriendFormState build() {
    return const FriendFormState();
  }

  Future<void> createFriend({
    required String userId,
    required String name,
    required String role,
    required String goal,
    required String personality,
    required String tone,
    required String responseStyle,
    required String boundaries,
    required String avatarType,
    required String voiceType,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSavedFriend: true,
    );

    try {
      final uuid = ref.read(uuidProvider);
      final createFriendUseCase = ref.read(createFriendUseCaseProvider);
      final generateFriendPromptUseCase = ref.read(
        generateFriendPromptUseCaseProvider,
      );

      final now = DateTime.now();

      final trimmedName = name.trim();
      final trimmedRole = role.trim();
      final trimmedGoal = goal.trim();
      final trimmedPersonality = personality.trim();
      final trimmedTone = tone.trim();
      final trimmedResponseStyle = responseStyle.trim();
      final trimmedBoundaries = boundaries.trim();

      final systemPrompt = generateFriendPromptUseCase.execute(
        name: trimmedName,
        role: trimmedRole,
        goal: trimmedGoal,
        personality: trimmedPersonality,
        tone: trimmedTone,
        responseStyle: trimmedResponseStyle,
        boundaries: trimmedBoundaries,
      );

      final friend = FriendEntity(
        id: uuid.v4(),
        userId: userId,
        name: trimmedName,
        role: trimmedRole,
        goal: trimmedGoal,
        personality: trimmedPersonality,
        tone: trimmedTone,
        responseStyle: trimmedResponseStyle,
        boundaries: trimmedBoundaries,
        avatarType: avatarType,
        voiceType: voiceType,
        systemPrompt: systemPrompt,
        syncStatus: SyncStatus.pendingCreate,
        createdAt: now,
        updatedAt: now,
      );

      await createFriendUseCase.execute(friend);

      state = state.copyWith(isLoading: false, savedFriend: friend);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> updateFriend(FriendEntity friend) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSavedFriend: true,
    );

    try {
      final updateFriendUseCase = ref.read(updateFriendUseCaseProvider);
      final generateFriendPromptUseCase = ref.read(
        generateFriendPromptUseCaseProvider,
      );

      final systemPrompt = generateFriendPromptUseCase.execute(
        name: friend.name,
        role: friend.role,
        goal: friend.goal,
        personality: friend.personality,
        tone: friend.tone,
        responseStyle: friend.responseStyle,
        boundaries: friend.boundaries,
      );

      final updatedFriend = FriendEntity(
        id: friend.id,
        userId: friend.userId,
        name: friend.name,
        role: friend.role,
        goal: friend.goal,
        personality: friend.personality,
        tone: friend.tone,
        responseStyle: friend.responseStyle,
        boundaries: friend.boundaries,
        avatarType: friend.avatarType,
        voiceType: friend.voiceType,
        systemPrompt: systemPrompt,
        syncStatus: SyncStatus.pendingUpdate,
        createdAt: friend.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: friend.deletedAt,
      );

      await updateFriendUseCase.execute(updatedFriend);

      state = state.copyWith(isLoading: false, savedFriend: updatedFriend);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}

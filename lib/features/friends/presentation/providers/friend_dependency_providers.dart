import 'package:ai_buddy/core/database/hive_box_names.dart';
import 'package:ai_buddy/features/friends/data/datasources/friend_local_datasource.dart';
import 'package:ai_buddy/features/friends/data/models/friend_model.dart';
import 'package:ai_buddy/features/friends/data/repositories/friend_repository_impl.dart';
import 'package:ai_buddy/features/friends/domain/repositories/friend_repository.dart';
import 'package:ai_buddy/features/friends/domain/usecases/create_friend_usecase.dart';
import 'package:ai_buddy/features/friends/domain/usecases/delete_friend_usecase.dart';
import 'package:ai_buddy/features/friends/domain/usecases/generate_friend_prompt_usecase.dart';
import 'package:ai_buddy/features/friends/domain/usecases/get_friend_by_id_usecase.dart';
import 'package:ai_buddy/features/friends/domain/usecases/get_friends_usecase.dart';
import 'package:ai_buddy/features/friends/domain/usecases/update_friend_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

final friendBoxProvider = Provider<Box<FriendModel>>((ref) {
  return Hive.box<FriendModel>(HiveBoxNames.friends);
});

final friendLocalDataSourceProvider = Provider<FriendLocalDataSource>((ref) {
  return FriendLocalDataSourceImpl(friendBox: ref.watch(friendBoxProvider));
});

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepositoryImpl(
    localDataSource: ref.watch(friendLocalDataSourceProvider),
  );
});

final getFriendsUseCaseProvider = Provider<GetFriendsUseCase>((ref) {
  return GetFriendsUseCase(ref.watch(friendRepositoryProvider));
});

final getFriendByIdUseCaseProvider = Provider<GetFriendByIdUseCase>((ref) {
  return GetFriendByIdUseCase(ref.watch(friendRepositoryProvider));
});

final createFriendUseCaseProvider = Provider<CreateFriendUseCase>((ref) {
  return CreateFriendUseCase(ref.watch(friendRepositoryProvider));
});

final updateFriendUseCaseProvider = Provider<UpdateFriendUseCase>((ref) {
  return UpdateFriendUseCase(ref.watch(friendRepositoryProvider));
});

final deleteFriendUseCaseProvider = Provider<DeleteFriendUseCase>((ref) {
  return DeleteFriendUseCase(ref.watch(friendRepositoryProvider));
});

final generateFriendPromptUseCaseProvider =
    Provider<GenerateFriendPromptUseCase>((ref) {
      return const GenerateFriendPromptUseCase();
    });

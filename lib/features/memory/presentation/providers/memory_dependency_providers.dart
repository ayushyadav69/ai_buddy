import 'package:ai_buddy/core/database/hive_box_names.dart';
import 'package:ai_buddy/features/memory/data/datasources/memory_local_datasource.dart';
import 'package:ai_buddy/features/memory/data/models/friend_memory_model.dart';
import 'package:ai_buddy/features/memory/data/repositories/memory_repository_impl.dart';
import 'package:ai_buddy/features/memory/domain/repositories/memory_repository.dart';
import 'package:ai_buddy/features/memory/domain/usecases/delete_friend_memory_usecase.dart';
import 'package:ai_buddy/features/memory/domain/usecases/get_friend_memories_usecase.dart';
import 'package:ai_buddy/features/memory/domain/usecases/save_friend_memory_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

final memoryBoxProvider = Provider<Box<FriendMemoryModel>>((ref) {
  return Hive.box<FriendMemoryModel>(HiveBoxNames.memories);
});

final memoryLocalDataSourceProvider = Provider<MemoryLocalDataSource>((ref) {
  return MemoryLocalDataSourceImpl(memoryBox: ref.watch(memoryBoxProvider));
});

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepositoryImpl(
    localDataSource: ref.watch(memoryLocalDataSourceProvider),
  );
});

final getFriendMemoriesUseCaseProvider = Provider<GetFriendMemoriesUseCase>((
  ref,
) {
  return GetFriendMemoriesUseCase(ref.watch(memoryRepositoryProvider));
});

final saveFriendMemoryUseCaseProvider = Provider<SaveFriendMemoryUseCase>((
  ref,
) {
  return SaveFriendMemoryUseCase(ref.watch(memoryRepositoryProvider));
});

final deleteFriendMemoryUseCaseProvider = Provider<DeleteFriendMemoryUseCase>((
  ref,
) {
  return DeleteFriendMemoryUseCase(ref.watch(memoryRepositoryProvider));
});

import 'package:ai_buddy/core/database/hive_box_names.dart';
import 'package:ai_buddy/core/providers/core_providers.dart';
import 'package:ai_buddy/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:ai_buddy/features/chat/data/models/chat_model.dart';
import 'package:ai_buddy/features/chat/data/models/message_model.dart';
import 'package:ai_buddy/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:ai_buddy/features/chat/domain/repositories/chat_repository.dart';
import 'package:ai_buddy/features/chat/domain/usecases/create_chat_usecase.dart';
import 'package:ai_buddy/features/chat/domain/usecases/get_chat_by_friend_id_usecase.dart';
import 'package:ai_buddy/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:ai_buddy/features/chat/domain/usecases/save_message_usecase.dart';
import 'package:ai_buddy/features/chat/domain/usecases/send_text_message_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:ai_buddy/features/ai/presentation/providers/ai_dependency_providers.dart';
import 'package:ai_buddy/features/friends/presentation/providers/friend_dependency_providers.dart';

final chatBoxProvider = Provider<Box<ChatModel>>((ref) {
  return Hive.box<ChatModel>(HiveBoxNames.chats);
});

final messageBoxProvider = Provider<Box<MessageModel>>((ref) {
  return Hive.box<MessageModel>(HiveBoxNames.messages);
});

final chatLocalDataSourceProvider = Provider<ChatLocalDataSource>((ref) {
  return ChatLocalDataSourceImpl(
    chatBox: ref.watch(chatBoxProvider),
    messageBox: ref.watch(messageBoxProvider),
  );
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    localDataSource: ref.watch(chatLocalDataSourceProvider),
  );
});

final createChatUseCaseProvider = Provider<CreateChatUseCase>((ref) {
  return CreateChatUseCase(ref.watch(chatRepositoryProvider));
});

final getChatByFriendIdUseCaseProvider = Provider<GetChatByFriendIdUseCase>((
  ref,
) {
  return GetChatByFriendIdUseCase(ref.watch(chatRepositoryProvider));
});

final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  return GetMessagesUseCase(ref.watch(chatRepositoryProvider));
});

final saveMessageUseCaseProvider = Provider<SaveMessageUseCase>((ref) {
  return SaveMessageUseCase(ref.watch(chatRepositoryProvider));
});

final sendTextMessageUseCaseProvider = Provider<SendTextMessageUseCase>((ref) {
  return SendTextMessageUseCase(
    chatRepository: ref.watch(chatRepositoryProvider),
    friendRepository: ref.watch(friendRepositoryProvider),
    aiRepository: ref.watch(aiRepositoryProvider),
    uuid: ref.watch(uuidProvider),
  );
});

import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/chat/domain/entities/ai_provider.dart';
import 'package:ai_buddy/features/chat/domain/entities/chat_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/presentation/providers/chat_dependency_providers.dart';
import 'package:ai_buddy/core/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatState {
  final bool isLoading;
  final bool isSending;
  final ChatEntity? chat;
  final List<MessageEntity> messages;
  final String? errorMessage;

  const ChatState({
    this.isLoading = false,
    this.isSending = false,
    this.chat,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    bool? isLoading,
    bool? isSending,
    ChatEntity? chat,
    List<MessageEntity>? messages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ChatViewModel extends Notifier<ChatState> {
  @override
  ChatState build() {
    return const ChatState();
  }

  Future<void> loadOrCreateChat({
    required String userId,
    required String friendId,
    required String friendName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final getChatByFriendIdUseCase = ref.read(
        getChatByFriendIdUseCaseProvider,
      );
      final createChatUseCase = ref.read(createChatUseCaseProvider);
      final getMessagesUseCase = ref.read(getMessagesUseCaseProvider);
      final uuid = ref.read(uuidProvider);

      var chat = await getChatByFriendIdUseCase.execute(
        userId: userId,
        friendId: friendId,
      );

      if (chat == null) {
        final now = DateTime.now();

        chat = ChatEntity(
          id: uuid.v4(),
          userId: userId,
          friendId: friendId,
          title: friendName,
          aiProvider: AiProvider.gemini,
          syncStatus: SyncStatus.pendingCreate,
          createdAt: now,
          updatedAt: now,
        );

        await createChatUseCase.execute(chat);
      }

      final messages = await getMessagesUseCase.execute(chatId: chat.id);

      state = state.copyWith(isLoading: false, chat: chat, messages: messages);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> sendTextMessage({
    required String userId,
    required String friendId,
    required String text,
  }) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return;
    }

    final chat = state.chat;

    if (chat == null) {
      state = state.copyWith(errorMessage: 'Chat is not ready yet.');
      return;
    }

    state = state.copyWith(isSending: true, clearError: true);

    try {
      final sendTextMessageUseCase = ref.read(sendTextMessageUseCaseProvider);
      final getMessagesUseCase = ref.read(getMessagesUseCaseProvider);

      await sendTextMessageUseCase.execute(
        userId: userId,
        friendId: friendId,
        chatId: chat.id,
        text: trimmedText,
      );

      final messages = await getMessagesUseCase.execute(chatId: chat.id);

      state = state.copyWith(isSending: false, messages: messages);
    } catch (error) {
      state = state.copyWith(isSending: false, errorMessage: error.toString());
    }
  }
}

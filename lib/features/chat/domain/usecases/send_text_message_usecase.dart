import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_status.dart';
import 'package:ai_buddy/features/chat/domain/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class SendTextMessageUseCase {
  final ChatRepository repository;
  final Uuid uuid;

  const SendTextMessageUseCase({required this.repository, required this.uuid});

  Future<MessageEntity> execute({
    required String userId,
    required String friendId,
    required String chatId,
    required String text,
  }) async {
    final now = DateTime.now();

    final message = MessageEntity(
      id: uuid.v4(),
      userId: userId,
      friendId: friendId,
      chatId: chatId,
      sender: MessageSender.user,
      text: text.trim(),
      status: MessageStatus.sent,
      syncStatus: SyncStatus.pendingCreate,
      createdAt: now,
      updatedAt: now,
    );

    await repository.saveMessage(message);

    return message;
  }
}

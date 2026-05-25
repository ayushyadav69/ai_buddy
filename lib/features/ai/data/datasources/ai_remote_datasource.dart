import 'package:ai_buddy/features/ai/domain/entities/ai_reply_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';

abstract class AiRemoteDataSource {
  Future<AiReplyEntity> generateReply({
    required String systemPrompt,
    required List<MessageEntity> recentMessages,
    required String currentMessage,
  });
}

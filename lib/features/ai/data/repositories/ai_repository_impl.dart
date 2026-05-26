import 'package:ai_buddy/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:ai_buddy/features/ai/domain/entities/ai_reply_entity.dart';
import 'package:ai_buddy/features/ai/domain/repositories/ai_repository.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;

  const AiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AiReplyEntity> generateReply({
    required String systemPrompt,
    required List<MessageEntity> recentMessages,
    required String currentMessage,
    String? imagePath,
  }) {
    return remoteDataSource.generateReply(
      systemPrompt: systemPrompt,
      recentMessages: recentMessages,
      currentMessage: currentMessage,
      imagePath: imagePath,
    );
  }
}

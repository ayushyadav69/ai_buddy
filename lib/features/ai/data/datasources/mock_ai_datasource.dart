import 'package:ai_buddy/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:ai_buddy/features/ai/domain/entities/ai_reply_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/memory/domain/entities/friend_memory_entity.dart';
import 'package:ai_buddy/features/memory/domain/entities/memory_candidate_entity.dart';

class MockAiDataSource implements AiRemoteDataSource {
  const MockAiDataSource();

  @override
  Future<AiReplyEntity> generateReply({
    required String systemPrompt,
    required List<MessageEntity> recentMessages,
    required String currentMessage,
    String? imagePath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final hasImage = imagePath != null && imagePath.trim().isNotEmpty;

    return AiReplyEntity(
      reply: hasImage
          ? 'Mock reply: I can see that you added a photo and asked "$currentMessage". Soon Gemini will answer using the image.'
          : 'Mock reply: I understand you said "$currentMessage". Soon this will come from Gemini using this buddy persona.',
      emotion: 'encouraging',
      memoryCandidate: const MemoryCandidateEntity(
        shouldSave: false,
        text: '',
        category: MemoryCategory.none,
        importance: 0,
      ),
    );
  }
}

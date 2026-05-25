import 'package:ai_buddy/features/memory/domain/entities/memory_candidate_entity.dart';

class AiReplyEntity {
  final String reply;
  final String emotion;
  final MemoryCandidateEntity memoryCandidate;

  const AiReplyEntity({
    required this.reply,
    required this.emotion,
    required this.memoryCandidate,
  });
}

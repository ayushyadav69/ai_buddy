import 'package:ai_buddy/features/memory/domain/entities/friend_memory_entity.dart';

class MemoryCandidateEntity {
  final bool shouldSave;
  final String text;
  final MemoryCategory category;
  final int importance;

  const MemoryCandidateEntity({
    required this.shouldSave,
    required this.text,
    required this.category,
    required this.importance,
  });

  bool get canBeSaved {
    return shouldSave && text.trim().isNotEmpty && importance >= 3;
  }
}

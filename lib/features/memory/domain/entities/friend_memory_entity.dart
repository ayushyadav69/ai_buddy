import 'package:ai_buddy/core/sync/sync_status.dart';

class FriendMemoryEntity {
  final String id;
  final String userId;
  final String friendId;

  final String text;
  final MemoryCategory category;
  final int importance;

  final SyncStatus syncStatus;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const FriendMemoryEntity({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.text,
    required this.category,
    required this.importance,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isImportant => importance >= 3;

  bool get isDeleted => deletedAt != null;
}

enum MemoryCategory {
  preference,
  project,
  learningLevel,
  goal,
  personalContext,
  none,
}

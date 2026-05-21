import 'package:ai_buddy/core/sync/sync_status.dart';

class FriendEntity {
  final String id;
  final String userId;

  final String name;
  final String role;
  final String goal;
  final String personality;
  final String tone;
  final String responseStyle;
  final String boundaries;

  final String avatarType;
  final String voiceType;

  final String systemPrompt;

  final SyncStatus syncStatus;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const FriendEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.role,
    required this.goal,
    required this.personality,
    required this.tone,
    required this.responseStyle,
    required this.boundaries,
    required this.avatarType,
    required this.voiceType,
    required this.systemPrompt,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
}

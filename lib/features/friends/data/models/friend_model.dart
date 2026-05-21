import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/friends/domain/entities/friend_entity.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'friend_model.g.dart';

@HiveType(typeId: 1)
class FriendModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String goal;

  @HiveField(5)
  final String personality;

  @HiveField(6)
  final String tone;

  @HiveField(7)
  final String responseStyle;

  @HiveField(8)
  final String boundaries;

  @HiveField(9)
  final String avatarType;

  @HiveField(10)
  final String voiceType;

  @HiveField(11)
  final String systemPrompt;

  @HiveField(12)
  final String syncStatusValue;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  @HiveField(15)
  final DateTime? deletedAt;

  const FriendModel({
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
    required this.syncStatusValue,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  SyncStatus get syncStatus {
    return SyncStatus.values.firstWhere(
      (status) => status.name == syncStatusValue,
      orElse: () => SyncStatus.failed,
    );
  }

  factory FriendModel.fromEntity(FriendEntity entity) {
    return FriendModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      role: entity.role,
      goal: entity.goal,
      personality: entity.personality,
      tone: entity.tone,
      responseStyle: entity.responseStyle,
      boundaries: entity.boundaries,
      avatarType: entity.avatarType,
      voiceType: entity.voiceType,
      systemPrompt: entity.systemPrompt,
      syncStatusValue: entity.syncStatus.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  FriendEntity toEntity() {
    return FriendEntity(
      id: id,
      userId: userId,
      name: name,
      role: role,
      goal: goal,
      personality: personality,
      tone: tone,
      responseStyle: responseStyle,
      boundaries: boundaries,
      avatarType: avatarType,
      voiceType: voiceType,
      systemPrompt: systemPrompt,
      syncStatus: syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  FriendModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? role,
    String? goal,
    String? personality,
    String? tone,
    String? responseStyle,
    String? boundaries,
    String? avatarType,
    String? voiceType,
    String? systemPrompt,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return FriendModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      goal: goal ?? this.goal,
      personality: personality ?? this.personality,
      tone: tone ?? this.tone,
      responseStyle: responseStyle ?? this.responseStyle,
      boundaries: boundaries ?? this.boundaries,
      avatarType: avatarType ?? this.avatarType,
      voiceType: voiceType ?? this.voiceType,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      syncStatusValue: syncStatus?.name ?? syncStatusValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

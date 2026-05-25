import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/memory/domain/entities/friend_memory_entity.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'friend_memory_model.g.dart';

@HiveType(typeId: 4)
class FriendMemoryModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String friendId;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final String categoryValue;

  @HiveField(5)
  final int importance;

  @HiveField(6)
  final String syncStatusValue;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final DateTime? deletedAt;

  const FriendMemoryModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.text,
    required this.categoryValue,
    required this.importance,
    required this.syncStatusValue,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  MemoryCategory get category {
    return MemoryCategory.values.firstWhere(
      (category) => category.name == categoryValue,
      orElse: () => MemoryCategory.none,
    );
  }

  SyncStatus get syncStatus {
    return SyncStatus.values.firstWhere(
      (status) => status.name == syncStatusValue,
      orElse: () => SyncStatus.failed,
    );
  }

  factory FriendMemoryModel.fromEntity(FriendMemoryEntity entity) {
    return FriendMemoryModel(
      id: entity.id,
      userId: entity.userId,
      friendId: entity.friendId,
      text: entity.text,
      categoryValue: entity.category.name,
      importance: entity.importance,
      syncStatusValue: entity.syncStatus.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  FriendMemoryEntity toEntity() {
    return FriendMemoryEntity(
      id: id,
      userId: userId,
      friendId: friendId,
      text: text,
      category: category,
      importance: importance,
      syncStatus: syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  FriendMemoryModel copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? text,
    MemoryCategory? category,
    int? importance,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return FriendMemoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      text: text ?? this.text,
      categoryValue: category?.name ?? categoryValue,
      importance: importance ?? this.importance,
      syncStatusValue: syncStatus?.name ?? syncStatusValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

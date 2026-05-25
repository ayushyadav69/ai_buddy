import 'package:ai_buddy/core/database/hive_box_names.dart';
import 'package:ai_buddy/features/chat/data/models/chat_model.dart';
import 'package:ai_buddy/features/chat/data/models/message_model.dart';
import 'package:ai_buddy/features/friends/data/models/friend_model.dart';
import 'package:ai_buddy/features/memory/data/models/friend_memory_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveConfig {
  const HiveConfig._();

  static Future<void> initialize() async {
    await Hive.initFlutter();

    Hive.registerAdapter(FriendModelAdapter());
    Hive.registerAdapter(ChatModelAdapter());
    Hive.registerAdapter(MessageModelAdapter());
    Hive.registerAdapter(FriendMemoryModelAdapter());

    await Hive.openBox<FriendModel>(HiveBoxNames.friends);
    await Hive.openBox<ChatModel>(HiveBoxNames.chats);
    await Hive.openBox<MessageModel>(HiveBoxNames.messages);
    await Hive.openBox<FriendMemoryModel>(HiveBoxNames.memories);
  }
}

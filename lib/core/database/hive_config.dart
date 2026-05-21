import 'package:ai_buddy/core/database/hive_box_names.dart';
import 'package:ai_buddy/features/friends/data/models/friend_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveConfig {
  const HiveConfig._();

  static Future<void> initialize() async {
    await Hive.initFlutter();

    Hive.registerAdapter(FriendModelAdapter());

    await Hive.openBox<FriendModel>(HiveBoxNames.friends);
  }
}

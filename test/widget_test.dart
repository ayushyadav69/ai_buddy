// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:ai_buddy/app/app.dart';
import 'package:ai_buddy/core/database/hive_box_names.dart';
import 'package:ai_buddy/features/friends/data/models/friend_model.dart';
import 'package:ai_buddy/features/chat/data/models/chat_model.dart';
import 'package:ai_buddy/features/chat/data/models/message_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:ai_buddy/features/memory/data/models/friend_memory_model.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ai_buddy_test_');

    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FriendModelAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ChatModelAdapter());
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MessageModelAdapter());
    }

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(FriendMemoryModelAdapter());
    }

    await Hive.openBox<FriendModel>(HiveBoxNames.friends);
    await Hive.openBox<ChatModel>(HiveBoxNames.chats);
    await Hive.openBox<MessageModel>(HiveBoxNames.messages);
    await Hive.openBox<FriendMemoryModel>(HiveBoxNames.memories);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('App shows empty friend list initially', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AiBuddyApp()));

    await tester.pumpAndSettle();

    expect(find.text('AI Buddies'), findsOneWidget);
    expect(
      find.text('No buddies yet. Create your first buddy.'),
      findsOneWidget,
    );
  });
}

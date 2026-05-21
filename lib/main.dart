import 'package:ai_buddy/app/app.dart';
import 'package:ai_buddy/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_buddy/core/database/hive_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await HiveConfig.initialize();

  runApp(const ProviderScope(child: AiBuddyApp()));
}

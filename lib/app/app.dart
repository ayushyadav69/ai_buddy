import 'package:flutter/material.dart';
import 'package:ai_buddy/core/constants/app_constants.dart';

class AiBuddyApp extends StatelessWidget {
  const AiBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('AI Buddy Setup Done', style: TextStyle(fontSize: 22)),
        ),
      ),
    );
  }
}

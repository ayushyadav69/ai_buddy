import 'package:flutter/material.dart';

class AiBuddyApp extends StatelessWidget {
  const AiBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Buddy',
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

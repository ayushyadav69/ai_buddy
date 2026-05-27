import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:flutter/material.dart';

class BuddyVisualTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color softColor;
  final IconData icon;
  final List<String> decorations;
  final String roomTitle;
  final String roomSubtitle;

  const BuddyVisualTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.softColor,
    required this.icon,
    required this.decorations,
    required this.roomTitle,
    required this.roomSubtitle,
  });
}

extension BuddyVisualThemeX on BuddyDefinition {
  BuddyVisualTheme get visualTheme {
    switch (id) {
      case 'study_buddy':
        return const BuddyVisualTheme(
          primaryColor: Color(0xFF5B7CFA),
          secondaryColor: Color(0xFF9B8CFF),
          backgroundColor: Color(0xFFEFF3FF),
          softColor: Color(0xFFDDE6FF),
          icon: Icons.school_rounded,
          decorations: ['📚', '✏️', '⭐'],
          roomTitle: 'Study Room',
          roomSubtitle: 'Ask about homework, reading, or school doubts.',
        );

      case 'play_buddy':
        return const BuddyVisualTheme(
          primaryColor: Color(0xFFFF9F43),
          secondaryColor: Color(0xFFFFD166),
          backgroundColor: Color(0xFFFFF3DD),
          softColor: Color(0xFFFFE2B8),
          icon: Icons.sports_esports_rounded,
          decorations: ['⚽', '🎲', '🎈'],
          roomTitle: 'Play Zone',
          roomSubtitle: 'Play riddles, jokes, and fun safe games.',
        );

      case 'learn_buddy':
        return const BuddyVisualTheme(
          primaryColor: Color(0xFF7C4DFF),
          secondaryColor: Color(0xFF4DD0E1),
          backgroundColor: Color(0xFFF1E9FF),
          softColor: Color(0xFFE2D5FF),
          icon: Icons.lightbulb_rounded,
          decorations: ['💡', '🪐', '🔭'],
          roomTitle: 'Learning Lab',
          roomSubtitle: 'Explore facts, science, stories, and new words.',
        );

      case 'activity_buddy':
        return const BuddyVisualTheme(
          primaryColor: Color(0xFF00B894),
          secondaryColor: Color(0xFF55EFC4),
          backgroundColor: Color(0xFFE6FFF7),
          softColor: Color(0xFFCFF8EC),
          icon: Icons.palette_rounded,
          decorations: ['🎨', '🌈', '✨'],
          roomTitle: 'Activity Studio',
          roomSubtitle: 'Draw, move, create, and try simple activities.',
        );

      default:
        return const BuddyVisualTheme(
          primaryColor: Colors.deepPurple,
          secondaryColor: Colors.purpleAccent,
          backgroundColor: Color(0xFFF7F3FF),
          softColor: Color(0xFFF0E9FF),
          icon: Icons.smart_toy_rounded,
          decorations: ['⭐', '✨', '🌈'],
          roomTitle: 'Buddy Room',
          roomSubtitle: 'Talk with your buddy.',
        );
    }
  }
}

import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_state_controller.dart';
import 'package:flutter/material.dart';

class BuddyAvatarView extends StatelessWidget {
  final BuddyUiState state;

  const BuddyAvatarView({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final icon = switch (state.activity) {
      BuddyActivityState.idle => Icons.smart_toy_outlined,
      BuddyActivityState.listening => Icons.hearing,
      BuddyActivityState.thinking => Icons.psychology_alt_outlined,
      BuddyActivityState.talking => Icons.record_voice_over_outlined,
      BuddyActivityState.offline => Icons.wifi_off,
    };

    return CircleAvatar(radius: 44, child: Icon(icon, size: 44));
  }
}

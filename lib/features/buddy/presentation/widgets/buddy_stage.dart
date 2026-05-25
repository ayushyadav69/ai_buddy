import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_state_controller.dart';
import 'package:flutter/material.dart';

class BuddyStage extends StatelessWidget {
  final String friendName;
  final BuddyUiState state;

  const BuddyStage({required this.friendName, required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final activityText = switch (state.activity) {
      BuddyActivityState.idle => 'Idle',
      BuddyActivityState.listening => 'Listening',
      BuddyActivityState.thinking => 'Thinking',
      BuddyActivityState.talking => 'Talking',
      BuddyActivityState.offline => 'Offline',
    };

    final icon = switch (state.activity) {
      BuddyActivityState.idle => Icons.smart_toy_outlined,
      BuddyActivityState.listening => Icons.hearing,
      BuddyActivityState.thinking => Icons.psychology_alt_outlined,
      BuddyActivityState.talking => Icons.record_voice_over_outlined,
      BuddyActivityState.offline => Icons.wifi_off,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          CircleAvatar(radius: 40, child: Icon(icon, size: 42)),
          const SizedBox(height: 8),
          Text(friendName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '$activityText • ${state.emotion.name}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (state.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              state.subtitle!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

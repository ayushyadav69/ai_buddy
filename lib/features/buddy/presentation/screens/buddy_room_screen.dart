import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/buddy/presentation/widgets/buddy_rive_view.dart';
import 'package:flutter/material.dart';

class BuddyRoomScreen extends StatefulWidget {
  final BuddyDefinition buddy;

  const BuddyRoomScreen({required this.buddy, super.key});

  @override
  State<BuddyRoomScreen> createState() => _BuddyRoomScreenState();
}

class _BuddyRoomScreenState extends State<BuddyRoomScreen> {
  BuddyActivityState _activity = BuddyActivityState.idle;

  void _changeActivity(BuddyActivityState activity) {
    setState(() {
      _activity = activity;
    });
  }

  String get _statusText {
    switch (_activity) {
      case BuddyActivityState.idle:
        return 'Hi! I am ready.';
      case BuddyActivityState.listening:
        return 'I am listening...';
      case BuddyActivityState.thinking:
        return 'Let me think...';
      case BuddyActivityState.talking:
        return 'I am talking now!';
      case BuddyActivityState.offline:
        return 'I am taking a short break.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final buddy = widget.buddy;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F3FF),
        elevation: 0,
        centerTitle: true,
        title: Text(
          buddy.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () => _changeActivity(BuddyActivityState.idle),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BuddyRiveView(
                      assetPath: buddy.riveAsset,
                      activity: _activity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                buddy.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.3,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _BuddyActionBar(
                onListenTap: () =>
                    _changeActivity(BuddyActivityState.listening),
                onThinkTap: () => _changeActivity(BuddyActivityState.thinking),
                onTalkTap: () => _changeActivity(BuddyActivityState.talking),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuddyActionBar extends StatelessWidget {
  final VoidCallback onListenTap;
  final VoidCallback onThinkTap;
  final VoidCallback onTalkTap;

  const _BuddyActionBar({
    required this.onListenTap,
    required this.onThinkTap,
    required this.onTalkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BuddyActionButton(
            icon: Icons.hearing_rounded,
            label: 'Listen',
            onTap: onListenTap,
          ),
          _BuddyActionButton(
            icon: Icons.psychology_rounded,
            label: 'Think',
            onTap: onThinkTap,
          ),
          _BuddyActionButton(
            icon: Icons.record_voice_over_rounded,
            label: 'Talk',
            onTap: onTalkTap,
          ),
        ],
      ),
    );
  }
}

class _BuddyActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BuddyActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF0E9FF),
              child: Icon(icon, size: 30, color: Colors.deepPurple),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:flutter/material.dart';
import 'package:ai_buddy/features/buddy/presentation/widgets/buddy_rive_view.dart';

class BuddyRoomScreen extends StatelessWidget {
  final BuddyDefinition buddy;

  const BuddyRoomScreen({required this.buddy, super.key});

  @override
  Widget build(BuildContext context) {
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
                    child: BuddyRiveView(assetPath: buddy.riveAsset),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                buddy.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              _BuddyActionBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuddyActionBar extends StatelessWidget {
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BuddyActionButton(icon: Icons.mic_rounded, label: 'Talk'),
          _BuddyActionButton(icon: Icons.photo_camera_rounded, label: 'Photo'),
          _BuddyActionButton(icon: Icons.videocam_rounded, label: 'Video'),
        ],
      ),
    );
  }
}

class _BuddyActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BuddyActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

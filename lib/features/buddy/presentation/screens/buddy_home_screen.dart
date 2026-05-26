import 'package:ai_buddy/features/buddy/domain/entities/default_buddies.dart';
import 'package:ai_buddy/features/buddy/presentation/screens/buddy_room_screen.dart';
import 'package:ai_buddy/features/buddy/presentation/widgets/buddy_home_card.dart';
import 'package:flutter/material.dart';

class BuddyHomeScreen extends StatelessWidget {
  const BuddyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buddies = DefaultBuddies.all;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(
                onProfileTap: () {
                  // Later we will open profile / parent area / history.
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Who do you want to talk with?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a buddy and start learning, playing, or creating.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: GridView.builder(
                  itemCount: buddies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final buddy = buddies[index];

                    return BuddyHomeCard(
                      buddy: buddy,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BuddyRoomScreen(buddy: buddy),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;

  const _HomeHeader({required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'AI Buddy',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
        ),
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded),
          ),
        ),
      ],
    );
  }
}

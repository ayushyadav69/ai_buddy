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
      backgroundColor: const Color(0xFFF8F0FF),
      body: Stack(
        children: [
          const _PlayfulBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HomeHeader(
                          onProfileTap: () {
                            // Later: profile / parent area / history.
                          },
                        ),
                        const SizedBox(height: 22),
                        const _WelcomePanel(),
                        const SizedBox(height: 24),
                        const Text(
                          'Pick your room',
                          style: TextStyle(
                            fontSize: 24,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Each buddy helps you in a different way.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: buddies.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 18),
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
        ],
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
          child: Row(
            children: [
              Text('🔥', style: TextStyle(fontSize: 32)),
              SizedBox(width: 8),
              Text(
                'AI Buddy',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, color: Colors.deepPurple),
          ),
        ),
      ],
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFFFF7AC8)],
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your buddy!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Talk, learn, play, and ask about photos.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Text('🎮', style: TextStyle(fontSize: 50)),
        ],
      ),
    );
  }
}

class _PlayfulBackground extends StatelessWidget {
  const _PlayfulBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF7D6), Color(0xFFF8F0FF), Color(0xFFEAF8FF)],
            ),
          ),
          child: SizedBox.expand(),
        ),
        Positioned(
          top: -70,
          right: -50,
          child: _Blob(
            size: 190,
            color: const Color(0xFFFFBFE5).withValues(alpha: 0.75),
          ),
        ),
        Positioned(
          top: 210,
          left: -75,
          child: _Blob(
            size: 165,
            color: const Color(0xFFB8E8FF).withValues(alpha: 0.72),
          ),
        ),
        Positioned(
          bottom: -95,
          right: -50,
          child: _Blob(
            size: 230,
            color: const Color(0xFFFFE5A8).withValues(alpha: 0.85),
          ),
        ),
        Positioned(
          bottom: 220,
          left: -45,
          child: _Blob(
            size: 110,
            color: const Color(0xFFD7C7FF).withValues(alpha: 0.45),
          ),
        ),
        const Positioned(
          top: 105,
          right: 34,
          child: Text('⭐', style: TextStyle(fontSize: 24)),
        ),
        const Positioned(
          top: 270,
          right: 22,
          child: Text('🌈', style: TextStyle(fontSize: 30)),
        ),
        const Positioned(
          bottom: 150,
          left: 20,
          child: Text('✨', style: TextStyle(fontSize: 24)),
        ),
        const Positioned(
          bottom: 80,
          right: 32,
          child: Text('🎈', style: TextStyle(fontSize: 28)),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:ai_buddy/features/buddy/presentation/theme/buddy_visual_theme.dart';
import 'package:ai_buddy/features/buddy/presentation/widgets/buddy_rive_view.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class BuddyHomeCard extends StatelessWidget {
  final BuddyDefinition buddy;
  final VoidCallback onTap;

  const BuddyHomeCard({required this.buddy, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final visualTheme = buddy.visualTheme;

    return SizedBox(
      height: 190,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(36),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [visualTheme.primaryColor, visualTheme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    top: -28,
                    right: -22,
                    child: _SoftCircle(
                      size: 120,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    left: -28,
                    child: _SoftCircle(
                      size: 130,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 122,
                    child: _DecorationBubble(
                      text: visualTheme.decorations[0],
                      size: 42,
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 132,
                    child: _DecorationBubble(
                      text: visualTheme.decorations[1],
                      size: 36,
                    ),
                  ),
                  Positioned(
                    top: 66,
                    right: 22,
                    child: _DecorationBubble(
                      text: visualTheme.decorations[2],
                      size: 34,
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: 10,
                    child: _StandingMascot(assetPath: buddy.riveAsset),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 150, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RoomBadge(
                          icon: visualTheme.icon,
                          title: visualTheme.roomTitle,
                        ),
                        const Spacer(),
                        Text(
                          buddy.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          buddy.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Start',
                            style: TextStyle(
                              color: visualTheme.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomBadge extends StatelessWidget {
  final IconData icon;
  final String title;

  const _RoomBadge({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingMascot extends StatelessWidget {
  final String assetPath;

  const _StandingMascot({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      width: 145,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 126,
            width: 126,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            height: 96,
            width: 96,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          ),
          ClipOval(
            child: SizedBox(
              height: 128,
              width: 128,
              child: Transform.scale(
                scale: 1.45,
                child: BuddyRiveView(assetPath: assetPath, fit: rive.Fit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorationBubble extends StatelessWidget {
  final String text;
  final double size;

  const _DecorationBubble({required this.text, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Text(text, style: TextStyle(fontSize: size * 0.48)),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

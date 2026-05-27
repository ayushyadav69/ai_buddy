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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(34),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [visualTheme.primaryColor, visualTheme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: visualTheme.primaryColor.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 14,
                left: 14,
                child: _DecorationBubble(
                  text: visualTheme.decorations[0],
                  size: 42,
                ),
              ),
              Positioned(
                top: 22,
                right: 14,
                child: _DecorationBubble(
                  text: visualTheme.decorations[1],
                  size: 38,
                ),
              ),
              Positioned(
                bottom: 92,
                right: 18,
                child: _DecorationBubble(
                  text: visualTheme.decorations[2],
                  size: 34,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(visualTheme.icon, color: Colors.white, size: 24),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: BuddyRiveView(
                          assetPath: buddy.riveAsset,
                          fit: rive.Fit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            buddy.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: visualTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            buddy.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        color: Colors.white.withValues(alpha: 0.24),
        shape: BoxShape.circle,
      ),
      child: Text(text, style: TextStyle(fontSize: size * 0.48)),
    );
  }
}

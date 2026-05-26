import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:flutter/material.dart';
import 'package:ai_buddy/features/buddy/presentation/widgets/buddy_rive_view.dart';

class BuddyHomeCard extends StatelessWidget {
  final BuddyDefinition buddy;
  final VoidCallback onTap;

  const BuddyHomeCard({required this.buddy, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = _themeColor;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      BuddyRiveView(assetPath: buddy.riveAsset),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            buddy.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                buddy.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                buddy.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _themeColor {
    switch (buddy.id) {
      case 'study_buddy':
        return Colors.blue;
      case 'play_buddy':
        return Colors.orange;
      case 'learn_buddy':
        return Colors.purple;
      case 'activity_buddy':
        return Colors.green;
      default:
        return Colors.teal;
    }
  }
}

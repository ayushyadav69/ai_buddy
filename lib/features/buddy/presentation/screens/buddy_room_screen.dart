import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_room_controller.dart';
import 'package:ai_buddy/features/buddy/presentation/widgets/buddy_rive_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuddyRoomScreen extends ConsumerWidget {
  final BuddyDefinition buddy;

  const BuddyRoomScreen({required this.buddy, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = buddyRoomControllerProvider(buddy);
    final roomState = ref.watch(provider);
    final controller = ref.read(provider.notifier);

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
            onPressed: () {
              controller.stopSpeaking();
            },
            icon: const Icon(Icons.stop_circle_rounded),
            tooltip: 'Stop speaking',
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
                      activity: roomState.activity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _statusText(roomState),
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
              const SizedBox(height: 14),
              _BuddySpeechPanel(roomState: roomState),
              const SizedBox(height: 16),
              _BuddyActionBar(
                isListening: roomState.isListening,
                isProcessing: roomState.isProcessing,
                onMicTap: () {
                  if (roomState.isListening) {
                    controller.stopListening();
                  } else {
                    controller.startVoiceQuestion();
                  }
                },
                onPhotoTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo support will come next.'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(BuddyRoomState state) {
    if (state.errorMessage != null) {
      return 'Oops! Try again.';
    }

    switch (state.activity) {
      case BuddyActivityState.idle:
        return 'Tap Talk and ask me.';
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
}

class _BuddySpeechPanel extends StatelessWidget {
  final BuddyRoomState roomState;

  const _BuddySpeechPanel({required this.roomState});

  @override
  Widget build(BuildContext context) {
    final hasRecognizedText = roomState.recognizedText.trim().isNotEmpty;
    final hasAnswerText = roomState.answerText.trim().isNotEmpty;
    final hasError = roomState.errorMessage != null;

    if (!hasRecognizedText && !hasAnswerText && !hasError) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 170),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasRecognizedText) ...[
              const Text(
                'You said',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                roomState.recognizedText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (hasRecognizedText && hasAnswerText) const SizedBox(height: 12),
            if (hasAnswerText) ...[
              const Text(
                'Buddy said',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                roomState.answerText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (hasError) ...[
              const Text(
                'Problem',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                roomState.errorMessage!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BuddyActionBar extends StatelessWidget {
  final bool isListening;
  final bool isProcessing;
  final VoidCallback onMicTap;
  final VoidCallback onPhotoTap;

  const _BuddyActionBar({
    required this.isListening,
    required this.isProcessing,
    required this.onMicTap,
    required this.onPhotoTap,
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
            icon: isListening ? Icons.stop_rounded : Icons.mic_rounded,
            label: isListening ? 'Stop' : 'Talk',
            onTap: isProcessing ? null : onMicTap,
            isPrimary: true,
          ),
          _BuddyActionButton(
            icon: Icons.photo_camera_rounded,
            label: 'Photo',
            onTap: onPhotoTap,
          ),
        ],
      ),
    );
  }
}

class _BuddyActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _BuddyActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary
        ? Colors.deepPurple
        : const Color(0xFFF0E9FF);
    final iconColor = isPrimary ? Colors.white : Colors.deepPurple;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: backgroundColor,
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

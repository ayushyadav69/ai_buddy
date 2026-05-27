import 'dart:io';

import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_room_controller.dart';
import 'package:ai_buddy/features/buddy/presentation/theme/buddy_visual_theme.dart';
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
    final visualTheme = buddy.visualTheme;

    return Scaffold(
      backgroundColor: visualTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: visualTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          buddy.name,
          style: TextStyle(
            color: visualTheme.primaryColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.stopSpeaking,
            icon: Icon(
              Icons.stop_circle_rounded,
              color: visualTheme.primaryColor,
            ),
            tooltip: 'Stop speaking',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _RoomBackground(visualTheme: visualTheme),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  Expanded(
                    child: _BuddyRoomStage(
                      buddy: buddy,
                      activity: roomState.activity,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _statusText(roomState),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: visualTheme.primaryColor,
                      fontSize: 22,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    visualTheme.roomSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (roomState.capturedPhotoPath != null) ...[
                    _CapturedPhotoPreview(
                      photoPath: roomState.capturedPhotoPath!,
                      visualTheme: visualTheme,
                      onRemoveTap: controller.clearCapturedPhoto,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _BuddySpeechPanel(
                    roomState: roomState,
                    visualTheme: visualTheme,
                  ),
                  const SizedBox(height: 14),
                  _BuddyActionBar(
                    visualTheme: visualTheme,
                    isListening: roomState.isListening,
                    isProcessing: roomState.isProcessing,
                    isCapturingPhoto: roomState.isCapturingPhoto,
                    onMicTap: () {
                      if (roomState.isListening) {
                        controller.stopListening();
                      } else {
                        controller.startVoiceQuestion();
                      }
                    },
                    onPhotoTap: controller.capturePhoto,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(BuddyRoomState state) {
    if (state.errorMessage != null) {
      return 'Oops! Try again.';
    }

    if (state.isCapturingPhoto) {
      return 'Opening camera...';
    }

    switch (state.activity) {
      case BuddyActivityState.idle:
        return state.capturedPhotoPath == null
            ? 'Tap Talk and ask me.'
            : 'Now ask me about the photo.';
      case BuddyActivityState.listening:
        return 'I am listening...';
      case BuddyActivityState.thinking:
        return 'Let me think...';
      case BuddyActivityState.talking:
        return 'I am talking now!';
      case BuddyActivityState.celebrating:
        return 'Yay! Great job!';
      case BuddyActivityState.offline:
        return 'I am taking a short break.';
    }
  }
}

class _RoomBackground extends StatelessWidget {
  final BuddyVisualTheme visualTheme;

  const _RoomBackground({required this.visualTheme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 20,
          right: 28,
          child: Text(
            visualTheme.decorations[0],
            style: const TextStyle(fontSize: 26),
          ),
        ),
        Positioned(
          top: 160,
          left: 12,
          child: Text(
            visualTheme.decorations[1],
            style: const TextStyle(fontSize: 24),
          ),
        ),
        Positioned(
          bottom: 220,
          right: 20,
          child: Text(
            visualTheme.decorations[2],
            style: const TextStyle(fontSize: 24),
          ),
        ),
        Positioned(
          bottom: 90,
          left: 18,
          child: Text(
            visualTheme.decorations[0],
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}

class _BuddyRoomStage extends StatelessWidget {
  final BuddyDefinition buddy;
  final BuddyActivityState activity;

  const _BuddyRoomStage({required this.buddy, required this.activity});

  @override
  Widget build(BuildContext context) {
    final visualTheme = buddy.visualTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [visualTheme.primaryColor, visualTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: visualTheme.primaryColor.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: _RoomBlob(
                size: 150,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: -45,
              left: -35,
              child: _RoomBlob(
                size: 160,
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -28,
              child: _RoomBlob(
                size: 120,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              top: 22,
              left: 22,
              child: _RoomPill(
                icon: visualTheme.icon,
                text: visualTheme.roomTitle,
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: Text(
                visualTheme.decorations.first,
                style: const TextStyle(fontSize: 36),
              ),
            ),
            Center(
              child: SizedBox(
                height: 270,
                width: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 230,
                      width: 230,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                    ),
                    ClipOval(
                      child: SizedBox(
                        height: 215,
                        width: 215,
                        child: Transform.scale(
                          scale: 1.35,
                          child: BuddyRiveView(
                            assetPath: buddy.riveAsset,
                            activity: activity,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 34,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 12,
                  width: 108,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RoomPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapturedPhotoPreview extends StatelessWidget {
  final String photoPath;
  final BuddyVisualTheme visualTheme;
  final VoidCallback onRemoveTap;

  const _CapturedPhotoPreview({
    required this.photoPath,
    required this.visualTheme,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: visualTheme.primaryColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              File(photoPath),
              height: 90,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Photo added. Tap Talk and ask your buddy about it.',
              style: TextStyle(
                color: visualTheme.primaryColor,
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemoveTap,
            icon: Icon(Icons.close_rounded, color: visualTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}

class _BuddySpeechPanel extends StatelessWidget {
  final BuddyRoomState roomState;
  final BuddyVisualTheme visualTheme;

  const _BuddySpeechPanel({required this.roomState, required this.visualTheme});

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
      constraints: const BoxConstraints(maxHeight: 150),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: visualTheme.primaryColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasRecognizedText) ...[
              _PanelLabel(label: 'You said', color: visualTheme.primaryColor),
              const SizedBox(height: 4),
              Text(
                roomState.recognizedText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (hasRecognizedText && hasAnswerText) const SizedBox(height: 12),
            if (hasAnswerText) ...[
              _PanelLabel(label: 'Buddy said', color: visualTheme.primaryColor),
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
              const _PanelLabel(label: 'Problem', color: Colors.red),
              const SizedBox(height: 4),
              Text(
                roomState.errorMessage!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
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

class _PanelLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _PanelLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
    );
  }
}

class _BuddyActionBar extends StatelessWidget {
  final BuddyVisualTheme visualTheme;
  final bool isListening;
  final bool isProcessing;
  final bool isCapturingPhoto;
  final VoidCallback onMicTap;
  final VoidCallback onPhotoTap;

  const _BuddyActionBar({
    required this.visualTheme,
    required this.isListening,
    required this.isProcessing,
    required this.isCapturingPhoto,
    required this.onMicTap,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = isProcessing || isCapturingPhoto;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: visualTheme.primaryColor.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BuddyActionButton(
            icon: isListening ? Icons.stop_rounded : Icons.mic_rounded,
            label: isListening ? 'Stop' : 'Talk',
            onTap: isBusy ? null : onMicTap,
            backgroundColor: visualTheme.primaryColor,
            iconColor: Colors.white,
            textColor: visualTheme.primaryColor,
          ),
          _BuddyActionButton(
            icon: Icons.photo_camera_rounded,
            label: isCapturingPhoto ? 'Opening' : 'Photo',
            onTap: isBusy || isListening ? null : onPhotoTap,
            backgroundColor: visualTheme.softColor,
            iconColor: visualTheme.primaryColor,
            textColor: visualTheme.primaryColor,
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
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const _BuddyActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: backgroundColor,
                child: Icon(icon, size: 31, color: iconColor),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _RoomBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

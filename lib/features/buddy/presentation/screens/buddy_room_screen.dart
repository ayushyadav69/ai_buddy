import 'dart:io';

import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_room_controller.dart';
import 'package:ai_buddy/features/buddy/presentation/theme/buddy_visual_theme.dart';
import 'package:ai_buddy/features/buddy/presentation/widgets/buddy_rive_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuddyRoomScreen extends ConsumerStatefulWidget {
  final BuddyDefinition buddy;

  const BuddyRoomScreen({required this.buddy, super.key});

  @override
  ConsumerState<BuddyRoomScreen> createState() => _BuddyRoomScreenState();
}

class _BuddyRoomScreenState extends ConsumerState<BuddyRoomScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(buddyRoomControllerProvider(widget.buddy).notifier)
          .startRoomSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final buddy = widget.buddy;
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
                    activity: roomState.activity,
                    isConversationModeEnabled:
                        roomState.isConversationModeEnabled,
                    isListening: roomState.isListening,
                    isProcessing: roomState.isProcessing,
                    isCapturingPhoto: roomState.isCapturingPhoto,
                    onPrimaryTap: () {
                      if (roomState.activity == BuddyActivityState.talking ||
                          roomState.isProcessing) {
                        controller.interruptAndListen();
                        return;
                      }

                      if (roomState.isConversationModeEnabled) {
                        controller.stopRoomSession();
                      } else {
                        controller.startRoomSession();
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

    if (state.isProcessing) {
      return 'Let me think...';
    }

    switch (state.activity) {
      case BuddyActivityState.idle:
        if (state.capturedPhotoPath != null) {
          return 'Ask me about the photo.';
        }

        return state.isConversationModeEnabled
            ? 'I am ready. You can speak.'
            : 'Tap Start to talk.';
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
              'Photo added. Speak and ask your buddy about it.',
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
      return _EmptySpeechHint(visualTheme: visualTheme);
    }

    return SizedBox(
      width: double.infinity,
      height: 170,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (hasRecognizedText)
              _SpeechBubble(
                label: 'You said',
                text: roomState.recognizedText,
                color: visualTheme.primaryColor,
                backgroundColor: visualTheme.softColor,
                alignRight: true,
              ),
            if (hasRecognizedText && hasAnswerText) const SizedBox(height: 10),
            if (hasAnswerText)
              _SpeechBubble(
                label: 'Buddy said',
                text: roomState.answerText,
                color: visualTheme.primaryColor,
                backgroundColor: Colors.white,
                alignRight: false,
              ),
            if (hasError)
              _SpeechBubble(
                label: 'Problem',
                text: roomState.errorMessage!,
                color: Colors.red,
                backgroundColor: const Color(0xFFFFECEC),
                alignRight: false,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptySpeechHint extends StatelessWidget {
  final BuddyVisualTheme visualTheme;

  const _EmptySpeechHint({required this.visualTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: visualTheme.primaryColor.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: visualTheme.softColor,
            child: Icon(
              Icons.tips_and_updates_rounded,
              color: visualTheme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your buddy will greet you. Then just speak naturally.',
              style: TextStyle(
                color: visualTheme.primaryColor,
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String label;
  final String text;
  final Color color;
  final Color backgroundColor;
  final bool alignRight;

  const _SpeechBubble({
    required this.label,
    required this.text,
    required this.color,
    required this.backgroundColor,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(alignRight ? 24 : 8),
            bottomRight: Radius.circular(alignRight ? 8 : 24),
          ),
          border: Border.all(color: color.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: alignRight
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: alignRight ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 15.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuddyActionBar extends StatelessWidget {
  final BuddyVisualTheme visualTheme;
  final BuddyActivityState activity;
  final bool isConversationModeEnabled;
  final bool isListening;
  final bool isProcessing;
  final bool isCapturingPhoto;
  final VoidCallback onPrimaryTap;
  final VoidCallback onPhotoTap;

  const _BuddyActionBar({
    required this.visualTheme,
    required this.activity,
    required this.isConversationModeEnabled,
    required this.isListening,
    required this.isProcessing,
    required this.isCapturingPhoto,
    required this.onPrimaryTap,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPhotoDisabled =
        isCapturingPhoto ||
        isListening ||
        isProcessing ||
        activity == BuddyActivityState.talking;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
        children: [
          Expanded(
            child: _PrimaryVoiceButton(
              visualTheme: visualTheme,
              activity: activity,
              isConversationModeEnabled: isConversationModeEnabled,
              isDisabled: isCapturingPhoto,
              onTap: onPrimaryTap,
            ),
          ),
          const SizedBox(width: 12),
          _PhotoButton(
            visualTheme: visualTheme,
            isCapturingPhoto: isCapturingPhoto,
            isDisabled: isPhotoDisabled,
            onTap: onPhotoTap,
          ),
        ],
      ),
    );
  }
}

class _PrimaryVoiceButton extends StatelessWidget {
  final BuddyVisualTheme visualTheme;
  final BuddyActivityState activity;
  final bool isConversationModeEnabled;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PrimaryVoiceButton({
    required this.visualTheme,
    required this.activity,
    required this.isConversationModeEnabled,
    required this.isDisabled,
    required this.onTap,
  });

  String get _label {
    if (activity == BuddyActivityState.talking ||
        activity == BuddyActivityState.thinking) {
      return 'Interrupt';
    }

    if (isConversationModeEnabled) {
      return 'End';
    }

    return 'Start';
  }

  IconData get _icon {
    if (activity == BuddyActivityState.talking ||
        activity == BuddyActivityState.thinking) {
      return Icons.pan_tool_rounded;
    }

    if (isConversationModeEnabled) {
      return Icons.stop_rounded;
    }

    return Icons.mic_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(26),
      child: Opacity(
        opacity: isDisabled ? 0.55 : 1,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [visualTheme.primaryColor, visualTheme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: visualTheme.primaryColor.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                _label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
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

class _PhotoButton extends StatelessWidget {
  final BuddyVisualTheme visualTheme;
  final bool isCapturingPhoto;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PhotoButton({
    required this.visualTheme,
    required this.isCapturingPhoto,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Opacity(
        opacity: isDisabled ? 0.55 : 1,
        child: Container(
          height: 72,
          width: 82,
          decoration: BoxDecoration(
            color: visualTheme.softColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: visualTheme.primaryColor.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera_rounded,
                color: visualTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(height: 5),
              Text(
                isCapturingPhoto ? 'Opening' : 'Photo',
                style: TextStyle(
                  color: visualTheme.primaryColor,
                  fontSize: 12,
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

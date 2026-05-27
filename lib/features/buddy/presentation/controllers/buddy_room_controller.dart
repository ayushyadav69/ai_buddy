import 'dart:async';

import 'package:ai_buddy/features/ai/presentation/providers/ai_dependency_providers.dart';
import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/media/data/services/photo_picker_service.dart';
import 'package:ai_buddy/features/media/presentation/providers/media_dependency_providers.dart';
import 'package:ai_buddy/features/voice/data/services/voice_input_service.dart';
import 'package:ai_buddy/features/voice/data/services/voice_output_service.dart';
import 'package:ai_buddy/features/voice/presentation/providers/voice_dependency_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final buddyRoomControllerProvider =
    NotifierProvider.family<
      BuddyRoomController,
      BuddyRoomState,
      BuddyDefinition
    >(BuddyRoomController.new);

class BuddyRoomState {
  final BuddyActivityState activity;
  final String recognizedText;
  final String answerText;
  final String? errorMessage;
  final String? capturedPhotoPath;
  final bool isListening;
  final bool isProcessing;
  final bool isCapturingPhoto;

  const BuddyRoomState({
    this.activity = BuddyActivityState.idle,
    this.recognizedText = '',
    this.answerText = '',
    this.errorMessage,
    this.capturedPhotoPath,
    this.isListening = false,
    this.isProcessing = false,
    this.isCapturingPhoto = false,
  });

  BuddyRoomState copyWith({
    BuddyActivityState? activity,
    String? recognizedText,
    String? answerText,
    String? errorMessage,
    String? capturedPhotoPath,
    bool? isListening,
    bool? isProcessing,
    bool? isCapturingPhoto,
    bool clearError = false,
    bool clearCapturedPhoto = false,
  }) {
    return BuddyRoomState(
      activity: activity ?? this.activity,
      recognizedText: recognizedText ?? this.recognizedText,
      answerText: answerText ?? this.answerText,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      capturedPhotoPath: clearCapturedPhoto
          ? null
          : capturedPhotoPath ?? this.capturedPhotoPath,
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      isCapturingPhoto: isCapturingPhoto ?? this.isCapturingPhoto,
    );
  }
}

class BuddyRoomController extends Notifier<BuddyRoomState> {
  BuddyRoomController(this.buddy);

  final BuddyDefinition buddy;

  late final VoiceInputService _voiceInputService;
  late final VoiceOutputService _voiceOutputService;
  late final PhotoPickerService _photoPickerService;

  @override
  BuddyRoomState build() {
    _voiceInputService = ref.read(voiceInputServiceProvider);
    _voiceOutputService = ref.read(voiceOutputServiceProvider);
    _photoPickerService = ref.read(photoPickerServiceProvider);

    ref.onDispose(() {
      unawaited(_voiceInputService.cancelListening());
      unawaited(_voiceOutputService.stop());
    });

    return const BuddyRoomState();
  }

  Future<void> startVoiceQuestion() async {
    if (state.isProcessing || state.isListening || state.isCapturingPhoto) {
      return;
    }

    await _voiceOutputService.stop();

    state = state.copyWith(
      activity: BuddyActivityState.listening,
      recognizedText: '',
      errorMessage: null,
      isListening: true,
      isProcessing: false,
      clearError: true,
    );

    await _voiceInputService.startListening(
      onResult: (words, isFinal) {
        state = state.copyWith(recognizedText: words);

        if (isFinal) {
          unawaited(_handleFinalSpeech(words));
        }
      },
      onError: (message) {
        state = state.copyWith(
          activity: BuddyActivityState.idle,
          errorMessage: message,
          isListening: false,
          isProcessing: false,
        );
      },
    );
  }

  Future<void> capturePhoto() async {
    if (state.isProcessing || state.isListening || state.isCapturingPhoto) {
      return;
    }

    await _voiceOutputService.stop();

    state = state.copyWith(
      activity: BuddyActivityState.thinking,
      isCapturingPhoto: true,
      clearError: true,
    );

    try {
      final photo = await _photoPickerService.takePhotoWithCamera();

      if (photo == null) {
        state = state.copyWith(
          activity: BuddyActivityState.idle,
          isCapturingPhoto: false,
        );
        return;
      }

      state = state.copyWith(
        activity: BuddyActivityState.idle,
        capturedPhotoPath: photo.path,
        isCapturingPhoto: false,
      );
    } catch (error) {
      state = state.copyWith(
        activity: BuddyActivityState.idle,
        errorMessage: error.toString(),
        isCapturingPhoto: false,
      );
    }
  }

  void clearCapturedPhoto() {
    state = state.copyWith(clearCapturedPhoto: true);
  }

  Future<void> stopListening() async {
    await _voiceInputService.stopListening();

    state = state.copyWith(
      activity: BuddyActivityState.idle,
      isListening: false,
    );
  }

  Future<void> stopSpeaking() async {
    await _voiceOutputService.stop();

    state = state.copyWith(activity: BuddyActivityState.idle);
  }

  Future<void> askTextQuestion(String question) async {
    final trimmedQuestion = question.trim();

    if (trimmedQuestion.isEmpty) {
      state = state.copyWith(
        activity: BuddyActivityState.idle,
        errorMessage: 'I could not hear anything. Please try again.',
        isListening: false,
        isProcessing: false,
      );

      return;
    }

    state = state.copyWith(
      activity: BuddyActivityState.thinking,
      recognizedText: trimmedQuestion,
      isListening: false,
      isProcessing: true,
      clearError: true,
    );

    try {
      final aiRepository = ref.read(aiRepositoryProvider);

      final capturedPhotoPath = state.capturedPhotoPath;

      final reply = await aiRepository.generateReply(
        systemPrompt: buddy.systemPrompt,
        recentMessages: const [],
        currentMessage: capturedPhotoPath == null
            ? trimmedQuestion
            : '''
The child has attached a photo and asked this question:

$trimmedQuestion

First look at the photo and the question.
Then decide if this photo question belongs to your buddy role.

If it belongs to your role:
- Answer using the photo.
- Keep the answer simple, safe, and easy for a child to understand.

If it does NOT belong to your role:
- Do not answer the full photo question.
- Gently suggest the correct buddy.
- Mention the exact buddy name.
- Keep the redirect short and friendly.
''',
        imagePath: capturedPhotoPath,
      );

      final answer = reply.reply.trim();

      if (answer.isEmpty) {
        state = state.copyWith(
          activity: BuddyActivityState.idle,
          errorMessage: 'I could not think of an answer. Please try again.',
          isProcessing: false,
        );

        return;
      }

      state = state.copyWith(
        activity: BuddyActivityState.talking,
        answerText: answer,
        isProcessing: false,
      );

      await _voiceOutputService.initialize(
        onStart: () {
          state = state.copyWith(activity: BuddyActivityState.talking);
        },
        onComplete: () {
          state = state.copyWith(activity: BuddyActivityState.celebrating);

          Future<void>.delayed(const Duration(seconds: 2), () {
            if (state.activity == BuddyActivityState.celebrating) {
              state = state.copyWith(activity: BuddyActivityState.idle);
            }
          });
        },
        onError: (message) {
          state = state.copyWith(
            activity: BuddyActivityState.idle,
            errorMessage: message,
          );
        },
      );

      await _voiceOutputService.speak(answer);
    } catch (error) {
      state = state.copyWith(
        activity: BuddyActivityState.idle,
        errorMessage: error.toString(),
        isListening: false,
        isProcessing: false,
      );
    }
  }

  Future<void> _handleFinalSpeech(String words) async {
    final trimmedWords = words.trim();

    await _voiceInputService.stopListening();

    if (trimmedWords.isEmpty) {
      state = state.copyWith(
        activity: BuddyActivityState.idle,
        errorMessage: 'I could not hear anything. Please try again.',
        isListening: false,
      );

      return;
    }

    await askTextQuestion(trimmedWords);
  }
}

import 'dart:async';

import 'package:ai_buddy/features/ai/presentation/providers/ai_dependency_providers.dart';
import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
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
  final bool isListening;
  final bool isProcessing;

  const BuddyRoomState({
    this.activity = BuddyActivityState.idle,
    this.recognizedText = '',
    this.answerText = '',
    this.errorMessage,
    this.isListening = false,
    this.isProcessing = false,
  });

  BuddyRoomState copyWith({
    BuddyActivityState? activity,
    String? recognizedText,
    String? answerText,
    String? errorMessage,
    bool? isListening,
    bool? isProcessing,
    bool clearError = false,
  }) {
    return BuddyRoomState(
      activity: activity ?? this.activity,
      recognizedText: recognizedText ?? this.recognizedText,
      answerText: answerText ?? this.answerText,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class BuddyRoomController extends Notifier<BuddyRoomState> {
  BuddyRoomController(this.buddy);

  final BuddyDefinition buddy;

  late final VoiceInputService _voiceInputService;
  late final VoiceOutputService _voiceOutputService;

  @override
  BuddyRoomState build() {
    _voiceInputService = ref.read(voiceInputServiceProvider);
    _voiceOutputService = ref.read(voiceOutputServiceProvider);

    ref.onDispose(() {
      unawaited(_voiceInputService.cancelListening());
      unawaited(_voiceOutputService.stop());
    });

    return const BuddyRoomState();
  }

  Future<void> startVoiceQuestion() async {
    if (state.isProcessing || state.isListening) {
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

      final reply = await aiRepository.generateReply(
        systemPrompt: buddy.systemPrompt,
        recentMessages: const [],
        currentMessage: trimmedQuestion,
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
          state = state.copyWith(activity: BuddyActivityState.idle);
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

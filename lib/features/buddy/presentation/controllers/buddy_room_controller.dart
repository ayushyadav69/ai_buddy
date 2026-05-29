import 'dart:async';

import 'package:ai_buddy/core/providers/core_providers.dart';
import 'package:ai_buddy/core/sync/sync_status.dart';
import 'package:ai_buddy/features/ai/presentation/providers/ai_dependency_providers.dart';
import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_status.dart';
import 'package:ai_buddy/features/chat/domain/repositories/chat_repository.dart';
import 'package:ai_buddy/features/chat/presentation/providers/chat_dependency_providers.dart';
import 'package:ai_buddy/features/media/data/services/photo_picker_service.dart';
import 'package:ai_buddy/features/media/presentation/providers/media_dependency_providers.dart';
import 'package:ai_buddy/features/memory/domain/entities/friend_memory_entity.dart';
import 'package:ai_buddy/features/memory/domain/entities/memory_candidate_entity.dart';
import 'package:ai_buddy/features/memory/domain/repositories/memory_repository.dart';
import 'package:ai_buddy/features/memory/presentation/providers/memory_dependency_providers.dart';
import 'package:ai_buddy/features/voice/data/services/voice_input_service.dart';
import 'package:ai_buddy/features/voice/data/services/voice_output_service.dart';
import 'package:ai_buddy/features/voice/presentation/providers/voice_dependency_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
  final List<MessageEntity> conversationMessages;
  final bool hasGreeted;
  final bool isConversationModeEnabled;
  final bool isListening;
  final bool isProcessing;
  final bool isCapturingPhoto;

  const BuddyRoomState({
    this.activity = BuddyActivityState.idle,
    this.recognizedText = '',
    this.answerText = '',
    this.errorMessage,
    this.capturedPhotoPath,
    this.conversationMessages = const [],
    this.hasGreeted = false,
    this.isConversationModeEnabled = false,
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
    List<MessageEntity>? conversationMessages,
    bool? hasGreeted,
    bool? isConversationModeEnabled,
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
      conversationMessages: conversationMessages ?? this.conversationMessages,
      hasGreeted: hasGreeted ?? this.hasGreeted,
      isConversationModeEnabled:
          isConversationModeEnabled ?? this.isConversationModeEnabled,
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      isCapturingPhoto: isCapturingPhoto ?? this.isCapturingPhoto,
    );
  }
}

class BuddyRoomController extends Notifier<BuddyRoomState> {
  BuddyRoomController(this.buddy);

  static const _localUserId = 'local_child';
  static const _maxContextMessages = 12;
  static const _maxMemoryContextItems = 8;

  final BuddyDefinition buddy;

  late final VoiceInputService _voiceInputService;
  late final VoiceOutputService _voiceOutputService;
  late final PhotoPickerService _photoPickerService;
  late final ChatRepository _chatRepository;
  late final MemoryRepository _memoryRepository;
  late final Uuid _uuid;

  Timer? _speechSilenceTimer;
  var _isHandlingFinalSpeech = false;

  var _isRoomActive = false;
  var _sessionToken = 0;

  @override
  BuddyRoomState build() {
    _voiceInputService = ref.read(voiceInputServiceProvider);
    _voiceOutputService = ref.read(voiceOutputServiceProvider);
    _photoPickerService = ref.read(photoPickerServiceProvider);
    _chatRepository = ref.read(chatRepositoryProvider);
    _memoryRepository = ref.read(memoryRepositoryProvider);
    _uuid = ref.read(uuidProvider);

    ref.onDispose(() {
      _invalidateSession();
      unawaited(_voiceInputService.cancelListening());
      unawaited(_voiceOutputService.stop());
    });

    return const BuddyRoomState();
  }

  Future<void> startRoomSession() async {
    _isRoomActive = true;
    _sessionToken++;
    final sessionToken = _sessionToken;

    if (state.hasGreeted) {
      if (!state.isConversationModeEnabled) {
        state = state.copyWith(isConversationModeEnabled: true);
        await startVoiceQuestion();
      }
      return;
    }

    final greeting = _greetingText();

    state = state.copyWith(
      hasGreeted: true,
      isConversationModeEnabled: true,
      activity: BuddyActivityState.idle,
      answerText: greeting,
      clearError: true,
    );

    await _voiceOutputService.initialize(
      onStart: () {
        if (!_isCurrentSession(sessionToken)) {
          return;
        }

        state = state.copyWith(activity: BuddyActivityState.talking);
      },
      onComplete: () {
        if (!_isCurrentSession(sessionToken)) {
          return;
        }

        state = state.copyWith(activity: BuddyActivityState.idle);

        Future<void>.delayed(const Duration(milliseconds: 350), () {
          if (!_isCurrentSession(sessionToken)) {
            return;
          }

          if (state.isConversationModeEnabled &&
              !state.isListening &&
              !state.isProcessing &&
              !state.isCapturingPhoto) {
            unawaited(startVoiceQuestion());
          }
        });
      },
      onError: (message) {
        if (!_isCurrentSession(sessionToken)) {
          return;
        }

        state = state.copyWith(
          activity: BuddyActivityState.idle,
          errorMessage: message,
        );
      },
    );

    if (!_isCurrentSession(sessionToken)) {
      return;
    }

    await _voiceOutputService.speak(greeting);
  }

  Future<void> stopRoomSession({bool resetGreeting = false}) async {
    _invalidateSession();

    await _voiceInputService.cancelListening();
    await _voiceOutputService.stop();

    state = state.copyWith(
      activity: BuddyActivityState.idle,
      hasGreeted: resetGreeting ? false : null,
      isConversationModeEnabled: false,
      isListening: false,
      isProcessing: false,
    );
  }

  Future<void> interruptAndListen() async {
    if (!_isRoomActive) {
      _isRoomActive = true;
      _sessionToken++;
    }

    final sessionToken = _sessionToken;

    _speechSilenceTimer?.cancel();

    await _voiceOutputService.stop();
    await _voiceInputService.cancelListening();

    if (!_isCurrentSession(sessionToken)) {
      return;
    }

    state = state.copyWith(
      activity: BuddyActivityState.idle,
      isConversationModeEnabled: true,
      isListening: false,
      isProcessing: false,
      clearError: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (_isCurrentSession(sessionToken)) {
      await startVoiceQuestion();
    }
  }

  Future<void> startVoiceQuestion() async {
    if (!_isRoomActive) {
      return;
    }

    if (state.isProcessing || state.isListening || state.isCapturingPhoto) {
      return;
    }

    final sessionToken = _sessionToken;

    _speechSilenceTimer?.cancel();
    _isHandlingFinalSpeech = false;

    await _voiceOutputService.stop();

    if (!_isCurrentSession(sessionToken)) {
      return;
    }

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
        if (!_isCurrentSession(sessionToken)) {
          return;
        }

        state = state.copyWith(recognizedText: words);

        if (isFinal) {
          unawaited(_handleFinalSpeech(words, sessionToken));
          return;
        }

        _scheduleSpeechFinalization(sessionToken);
      },
      onStatus: (status) {
        _handleSpeechStatus(status, sessionToken);
      },
      onError: (message) {
        if (!_isCurrentSession(sessionToken)) {
          return;
        }

        _speechSilenceTimer?.cancel();

        state = state.copyWith(
          activity: BuddyActivityState.idle,
          errorMessage: message,
          isListening: false,
          isProcessing: false,
        );

        if (state.isConversationModeEnabled) {
          _restartListeningAfterShortPause(sessionToken);
        }
      },
    );
  }

  void _handleSpeechStatus(String status, int sessionToken) {
    if (!_isCurrentSession(sessionToken)) {
      return;
    }

    final normalizedStatus = status.toLowerCase();

    final isTerminalStatus =
        normalizedStatus == 'done' || normalizedStatus == 'notlistening';

    if (!isTerminalStatus || !state.isListening) {
      return;
    }

    final words = state.recognizedText.trim();

    if (words.isEmpty) {
      return;
    }

    unawaited(_handleFinalSpeech(words, sessionToken));
  }

  void _scheduleSpeechFinalization(int sessionToken) {
    _speechSilenceTimer?.cancel();

    final words = state.recognizedText.trim();

    if (words.isEmpty) {
      return;
    }

    _speechSilenceTimer = Timer(const Duration(seconds: 2), () {
      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      if (!state.isListening || _isHandlingFinalSpeech) {
        return;
      }

      final latestWords = state.recognizedText.trim();

      if (latestWords.isEmpty) {
        return;
      }

      unawaited(_handleFinalSpeech(latestWords, sessionToken));
    });
  }

  Future<void> capturePhoto() async {
    if (!_isRoomActive) {
      return;
    }

    if (state.isProcessing || state.isListening || state.isCapturingPhoto) {
      return;
    }

    final sessionToken = _sessionToken;

    await _voiceOutputService.stop();

    if (!_isCurrentSession(sessionToken)) {
      return;
    }

    state = state.copyWith(
      activity: BuddyActivityState.thinking,
      isCapturingPhoto: true,
      clearError: true,
    );

    try {
      final photo = await _photoPickerService.takePhotoWithCamera();

      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      if (photo == null) {
        state = state.copyWith(
          activity: BuddyActivityState.idle,
          isCapturingPhoto: false,
        );

        if (state.isConversationModeEnabled) {
          _restartListeningAfterShortPause(sessionToken);
        }

        return;
      }

      state = state.copyWith(
        activity: BuddyActivityState.idle,
        capturedPhotoPath: photo.path,
        isCapturingPhoto: false,
      );

      if (state.isConversationModeEnabled) {
        _restartListeningAfterShortPause(sessionToken);
      }
    } catch (error) {
      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      state = state.copyWith(
        activity: BuddyActivityState.idle,
        errorMessage: error.toString(),
        isCapturingPhoto: false,
      );

      if (state.isConversationModeEnabled) {
        _restartListeningAfterShortPause(sessionToken);
      }
    }
  }

  void clearCapturedPhoto() {
    state = state.copyWith(clearCapturedPhoto: true);
  }

  Future<void> stopListening() async {
    final sessionToken = _sessionToken;
    final words = state.recognizedText.trim();

    _speechSilenceTimer?.cancel();

    await _voiceInputService.stopListening();

    if (!_isCurrentSession(sessionToken)) {
      return;
    }

    if (words.isEmpty) {
      state = state.copyWith(
        activity: BuddyActivityState.idle,
        isListening: false,
      );

      if (state.isConversationModeEnabled) {
        _restartListeningAfterShortPause(sessionToken);
      }

      return;
    }

    await _handleFinalSpeech(words, sessionToken);
  }

  Future<void> stopSpeaking() async {
    await _voiceOutputService.stop();

    if (!_isRoomActive) {
      return;
    }

    state = state.copyWith(activity: BuddyActivityState.idle);
  }

  Future<void> askTextQuestion(String question) async {
    final sessionToken = _sessionToken;

    if (!_isCurrentSession(sessionToken)) {
      return;
    }

    final trimmedQuestion = question.trim();

    if (trimmedQuestion.isEmpty) {
      state = state.copyWith(
        activity: BuddyActivityState.idle,
        errorMessage: 'I could not hear anything. Please try again.',
        isListening: false,
        isProcessing: false,
      );

      if (state.isConversationModeEnabled) {
        _restartListeningAfterShortPause(sessionToken);
      }

      return;
    }

    final capturedPhotoPath = state.capturedPhotoPath;
    final recentMessages = _recentContextMessages();
    final memoryContext = await _memoryContextForAi();

    if (!_isCurrentSession(sessionToken)) {
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

      final currentMessage = capturedPhotoPath == null
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

Also use the recent conversation context if the child is replying to something you asked earlier.
''';

      final reply = await aiRepository.generateReply(
        systemPrompt: _systemPromptWithMemory(memoryContext),
        recentMessages: recentMessages,
        currentMessage: currentMessage,
        imagePath: capturedPhotoPath,
      );

      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      final answer = reply.reply.trim();

      if (answer.isEmpty) {
        state = state.copyWith(
          activity: BuddyActivityState.idle,
          errorMessage: 'I could not think of an answer. Please try again.',
          isProcessing: false,
        );

        if (state.isConversationModeEnabled) {
          _restartListeningAfterShortPause(sessionToken);
        }

        return;
      }

      final updatedConversation = await _appendTurnToContext(
        userText: capturedPhotoPath == null
            ? trimmedQuestion
            : '[Photo attached] $trimmedQuestion',
        buddyText: answer,
        emotion: reply.emotion,
      );

      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      await _saveMemoryCandidate(reply.memoryCandidate);

      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      state = state.copyWith(
        activity: BuddyActivityState.thinking,
        answerText: answer,
        conversationMessages: updatedConversation,
        isProcessing: false,
      );

      await _voiceOutputService.initialize(
        onStart: () {
          if (!_isCurrentSession(sessionToken)) {
            return;
          }

          state = state.copyWith(activity: BuddyActivityState.talking);
        },
        onComplete: () {
          if (!_isCurrentSession(sessionToken)) {
            return;
          }

          state = state.copyWith(activity: BuddyActivityState.celebrating);

          Future<void>.delayed(const Duration(milliseconds: 900), () async {
            if (!_isCurrentSession(sessionToken)) {
              return;
            }

            if (state.activity != BuddyActivityState.celebrating) {
              return;
            }

            state = state.copyWith(activity: BuddyActivityState.idle);

            if (!state.isConversationModeEnabled) {
              return;
            }

            await Future<void>.delayed(const Duration(milliseconds: 300));

            if (!_isCurrentSession(sessionToken)) {
              return;
            }

            if (state.isConversationModeEnabled &&
                !state.isListening &&
                !state.isProcessing &&
                !state.isCapturingPhoto) {
              await startVoiceQuestion();
            }
          });
        },
        onError: (message) {
          if (!_isCurrentSession(sessionToken)) {
            return;
          }

          state = state.copyWith(
            activity: BuddyActivityState.idle,
            errorMessage: message,
          );

          if (state.isConversationModeEnabled) {
            _restartListeningAfterShortPause(sessionToken);
          }
        },
      );

      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      await _voiceOutputService.speak(answer);
    } catch (error) {
      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      state = state.copyWith(
        activity: BuddyActivityState.idle,
        errorMessage: error.toString(),
        isListening: false,
        isProcessing: false,
      );

      if (state.isConversationModeEnabled) {
        _restartListeningAfterShortPause(sessionToken);
      }
    }
  }

  Future<void> _handleFinalSpeech(String words, int sessionToken) async {
    if (!_isCurrentSession(sessionToken)) {
      return;
    }

    if (_isHandlingFinalSpeech) {
      return;
    }

    _isHandlingFinalSpeech = true;
    _speechSilenceTimer?.cancel();

    try {
      final trimmedWords = words.trim();

      await _voiceInputService.stopListening();

      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      if (trimmedWords.isEmpty) {
        state = state.copyWith(
          activity: BuddyActivityState.idle,
          errorMessage: 'I could not hear anything. Please try again.',
          isListening: false,
        );

        if (state.isConversationModeEnabled) {
          _restartListeningAfterShortPause(sessionToken);
        }

        return;
      }

      await askTextQuestion(trimmedWords);
    } finally {
      _isHandlingFinalSpeech = false;
    }
  }

  void _restartListeningAfterShortPause(int sessionToken) {
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!_isCurrentSession(sessionToken)) {
        return;
      }

      if (state.isConversationModeEnabled &&
          !state.isListening &&
          !state.isProcessing &&
          !state.isCapturingPhoto &&
          state.activity == BuddyActivityState.idle) {
        unawaited(startVoiceQuestion());
      }
    });
  }

  void _invalidateSession() {
    _isRoomActive = false;
    _sessionToken++;
    _isHandlingFinalSpeech = false;
    _speechSilenceTimer?.cancel();
  }

  bool _isCurrentSession(int sessionToken) {
    return _isRoomActive && _sessionToken == sessionToken;
  }

  String _greetingText() {
    switch (buddy.id) {
      case 'study_buddy':
        return 'Hi! I am Study Buddy. Ask me about homework, reading, or school questions.';
      case 'play_buddy':
        return 'Hi! I am Play Buddy. Ask me for jokes, riddles, or fun games.';
      case 'learn_buddy':
        return 'Hi! I am Learn Buddy. Ask me about facts, animals, space, or science.';
      case 'activity_buddy':
        return 'Hi! I am Activity Buddy. Ask me for drawing, craft, or fun movement ideas.';
      default:
        return 'Hi! I am your buddy. Ask me anything in my room.';
    }
  }

  String _systemPromptWithMemory(String memoryContext) {
    if (memoryContext.trim().isEmpty) {
      return buddy.systemPrompt;
    }

    return '''
${buddy.systemPrompt}

Useful long-term memories about this child for this buddy:
$memoryContext

Use these memories only when they help the current answer.
Do not mention that you are using saved memories.
Do not reveal memory storage details to the child.
''';
  }

  Future<String> _memoryContextForAi() async {
    try {
      final memories = await _memoryRepository.getMemories(friendId: buddy.id);

      final usefulMemories =
          memories
              .where((memory) => !memory.isDeleted)
              .where((memory) => memory.text.trim().isNotEmpty)
              .where((memory) => memory.category != MemoryCategory.none)
              .toList()
            ..sort((a, b) => b.importance.compareTo(a.importance));

      if (usefulMemories.isEmpty) {
        return '';
      }

      return usefulMemories
          .take(_maxMemoryContextItems)
          .map((memory) => '- ${memory.text.trim()}')
          .join('\n');
    } catch (_) {
      return '';
    }
  }

  List<MessageEntity> _recentContextMessages() {
    final messages = state.conversationMessages;

    if (messages.length <= _maxContextMessages) {
      return messages;
    }

    return messages.sublist(messages.length - _maxContextMessages);
  }

  Future<List<MessageEntity>> _appendTurnToContext({
    required String userText,
    required String buddyText,
    required String emotion,
  }) async {
    final now = DateTime.now();

    final userMessage = _contextMessage(
      id: _uuid.v4(),
      sender: MessageSender.user,
      text: userText,
      createdAt: now,
    );

    final buddyMessage = _contextMessage(
      id: _uuid.v4(),
      sender: MessageSender.buddy,
      text: buddyText,
      emotion: emotion,
      createdAt: now.add(const Duration(milliseconds: 1)),
    );

    await _saveMessageToDb(userMessage);
    await _saveMessageToDb(buddyMessage);

    final updatedMessages = [
      ...state.conversationMessages,
      userMessage,
      buddyMessage,
    ];

    if (updatedMessages.length <= _maxContextMessages) {
      return updatedMessages;
    }

    return updatedMessages.sublist(
      updatedMessages.length - _maxContextMessages,
    );
  }

  Future<void> _saveMessageToDb(MessageEntity message) async {
    try {
      await _chatRepository.saveMessage(message);
    } catch (_) {
      // Saving history should not break the live voice flow.
    }
  }

  Future<void> _saveMemoryCandidate(
    MemoryCandidateEntity memoryCandidate,
  ) async {
    if (!memoryCandidate.canBeSaved) {
      return;
    }

    final memoryText = memoryCandidate.text.trim();

    if (memoryText.isEmpty) {
      return;
    }

    try {
      final existingMemories = await _memoryRepository.getMemories(
        friendId: buddy.id,
      );

      final alreadyExists = existingMemories.any((memory) {
        return !memory.isDeleted &&
            memory.text.trim().toLowerCase() == memoryText.toLowerCase();
      });

      if (alreadyExists) {
        return;
      }

      final now = DateTime.now();

      final memory = FriendMemoryEntity(
        id: _uuid.v4(),
        userId: _localUserId,
        friendId: buddy.id,
        text: memoryText,
        category: memoryCandidate.category,
        importance: memoryCandidate.importance,
        syncStatus: SyncStatus.pendingCreate,
        createdAt: now,
        updatedAt: now,
      );

      await _memoryRepository.saveMemory(memory);
    } catch (_) {
      // Memory save should not break the live conversation.
    }
  }

  MessageEntity _contextMessage({
    required String id,
    required MessageSender sender,
    required String text,
    required DateTime createdAt,
    String? emotion,
  }) {
    return MessageEntity(
      id: id,
      userId: _localUserId,
      friendId: buddy.id,
      chatId: 'room-${buddy.id}',
      sender: sender,
      text: text,
      emotion: emotion,
      status: MessageStatus.sent,
      syncStatus: SyncStatus.pendingCreate,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}

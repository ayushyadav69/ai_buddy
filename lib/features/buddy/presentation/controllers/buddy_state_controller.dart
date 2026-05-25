import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_emotion_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuddyUiState {
  final BuddyActivityState activity;
  final BuddyEmotionState emotion;
  final String? subtitle;

  const BuddyUiState({
    this.activity = BuddyActivityState.idle,
    this.emotion = BuddyEmotionState.neutral,
    this.subtitle,
  });

  BuddyUiState copyWith({
    BuddyActivityState? activity,
    BuddyEmotionState? emotion,
    String? subtitle,
    bool clearSubtitle = false,
  }) {
    return BuddyUiState(
      activity: activity ?? this.activity,
      emotion: emotion ?? this.emotion,
      subtitle: clearSubtitle ? null : subtitle ?? this.subtitle,
    );
  }
}

class BuddyStateController extends Notifier<BuddyUiState> {
  @override
  BuddyUiState build() {
    return const BuddyUiState();
  }

  void setIdle() {
    state = state.copyWith(
      activity: BuddyActivityState.idle,
      emotion: BuddyEmotionState.neutral,
      clearSubtitle: true,
    );
  }

  void setListening() {
    state = state.copyWith(
      activity: BuddyActivityState.listening,
      emotion: BuddyEmotionState.neutral,
      subtitle: 'Listening...',
    );
  }

  void setThinking() {
    state = state.copyWith(
      activity: BuddyActivityState.thinking,
      emotion: BuddyEmotionState.neutral,
      subtitle: 'Thinking...',
    );
  }

  void setTalking({required String reply, required String emotion}) {
    state = state.copyWith(
      activity: BuddyActivityState.talking,
      emotion: _mapEmotion(emotion),
      subtitle: reply,
    );
  }

  void setOffline() {
    state = state.copyWith(
      activity: BuddyActivityState.offline,
      emotion: BuddyEmotionState.confused,
      subtitle: 'I am offline right now.',
    );
  }

  BuddyEmotionState _mapEmotion(String emotion) {
    return BuddyEmotionState.values.firstWhere(
      (value) => value.name == emotion,
      orElse: () => BuddyEmotionState.neutral,
    );
  }
}

import 'dart:async';

import 'package:ai_buddy/features/voice/data/services/voice_input_service.dart';
import 'package:ai_buddy/features/voice/data/services/voice_output_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voiceInputServiceProvider = Provider<VoiceInputService>((ref) {
  final service = VoiceInputService();

  ref.onDispose(() {
    unawaited(service.cancelListening());
  });

  return service;
});

final voiceOutputServiceProvider = Provider<VoiceOutputService>((ref) {
  final service = VoiceOutputService();

  ref.onDispose(() {
    unawaited(service.stop());
  });

  return service;
});

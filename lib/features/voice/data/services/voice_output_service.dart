import 'package:flutter_tts/flutter_tts.dart';

class VoiceOutputService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize({
    void Function()? onStart,
    void Function()? onComplete,
    void Function(String message)? onError,
  }) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      onStart?.call();
    });

    _tts.setCompletionHandler(() {
      onComplete?.call();
    });

    _tts.setCancelHandler(() {
      onComplete?.call();
    });

    _tts.setErrorHandler((message) {
      onError?.call(message);
    });
  }

  Future<void> speak(String text) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return;
    }

    await _tts.stop();
    await _tts.speak(trimmedText);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}

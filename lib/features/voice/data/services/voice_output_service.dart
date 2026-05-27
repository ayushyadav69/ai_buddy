import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceOutputService {
  final FlutterTts _tts = FlutterTts();

  var _isInitialized = false;

  Future<void> initialize({
    void Function()? onStart,
    void Function()? onComplete,
    void Function(String message)? onError,
  }) async {
    if (!_isInitialized) {
      await _configureVoice();
      _isInitialized = true;
    }

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

  Future<void> _configureVoice() async {
    await _tts.setLanguage('en-US');

    // Slower speech is easier for kids to understand.
    await _tts.setSpeechRate(0.38);

    // Keep pitch close to natural. Too high can sound cartoonish/robotic.
    await _tts.setPitch(0.95);

    await _tts.setVolume(1.0);

    await _tts.awaitSpeakCompletion(true);

    await _trySetFriendlyVoice();
  }

  Future<void> _trySetFriendlyVoice() async {
    try {
      final voices = await _tts.getVoices;

      if (voices is! List) {
        return;
      }

      final voiceMaps = voices.whereType<Map>().toList();

      if (voiceMaps.isEmpty) {
        return;
      }

      final englishVoices = voiceMaps.where((voice) {
        final locale = voice['locale']?.toString().toLowerCase() ?? '';
        final name = voice['name']?.toString().toLowerCase() ?? '';

        return locale.startsWith('en') || name.contains('english');
      }).toList();

      if (englishVoices.isEmpty) {
        return;
      }

      final preferredVoice = _bestVoiceFrom(englishVoices);

      debugPrint('Selected TTS voice: $preferredVoice');

      await _tts.setVoice({
        'name': preferredVoice['name'],
        'locale': preferredVoice['locale'],
      });
    } catch (error) {
      debugPrint('Could not set custom TTS voice: $error');
    }
  }

  Map _bestVoiceFrom(List<Map> voices) {
    final preferredKeywords = [
      // Android / Google voices often include these.
      'female',
      'natural',
      'enhanced',
      'network',
      'en-us',

      // iOS high-quality voices often include names.
      'samantha',
      'ava',
      'allison',
      'susan',
      'karen',
      'moira',
    ];

    for (final keyword in preferredKeywords) {
      for (final voice in voices) {
        final searchableText = [
          voice['name'],
          voice['locale'],
          voice['quality'],
          voice['gender'],
          voice['identifier'],
        ].whereType<Object>().join(' ').toLowerCase();

        if (searchableText.contains(keyword)) {
          return voice;
        }
      }
    }

    return voices.first;
  }

  Future<void> speak(String text) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return;
    }

    await _tts.stop();
    await _tts.speak(_makeSpeechKidFriendly(trimmedText));
  }

  String _makeSpeechKidFriendly(String text) {
    return text.replaceAll('\n', '. ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}

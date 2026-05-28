import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputService {
  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;

  void Function(String message)? _onError;
  void Function(String status)? _onStatus;

  bool get isListening => _speech.isListening;

  Future<bool> initialize({
    void Function(String message)? onError,
    void Function(String status)? onStatus,
  }) async {
    _onError = onError;
    _onStatus = onStatus;

    if (_isInitialized) {
      return _speech.isAvailable;
    }

    _isInitialized = await _speech.initialize(
      debugLogging: true,
      onError: (SpeechRecognitionError error) {
        _onError?.call(error.errorMsg);
      },
      onStatus: (String status) {
        _onStatus?.call(status);
      },
    );

    return _isInitialized;
  }

  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
    void Function(String message)? onError,
    void Function(String status)? onStatus,
  }) async {
    final isAvailable = await initialize(onError: onError, onStatus: onStatus);

    if (!isAvailable) {
      onError?.call('Speech recognition is not available.');
      return;
    }

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> stopListening() async {
    if (!_speech.isListening) {
      return;
    }

    await _speech.stop();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }
}

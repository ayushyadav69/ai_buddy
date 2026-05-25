class GeminiConfig {
  const GeminiConfig._();

  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const String model = 'gemini-3-flash-preview';

  static bool get hasApiKey => apiKey.trim().isNotEmpty;

  static Uri generateContentUri() {
    return Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );
  }
}

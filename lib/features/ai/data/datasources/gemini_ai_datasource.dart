import 'dart:convert';

import 'package:ai_buddy/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:ai_buddy/features/ai/data/datasources/gemini_config.dart';
import 'package:ai_buddy/features/ai/domain/entities/ai_reply_entity.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/memory/domain/entities/friend_memory_entity.dart';
import 'package:ai_buddy/features/memory/domain/entities/memory_candidate_entity.dart';
import 'package:http/http.dart' as http;

class GeminiAiDataSource implements AiRemoteDataSource {
  final http.Client client;

  const GeminiAiDataSource({required this.client});

  @override
  Future<AiReplyEntity> generateReply({
    required String systemPrompt,
    required List<MessageEntity> recentMessages,
    required String currentMessage,
  }) async {
    if (!GeminiConfig.hasApiKey) {
      throw Exception(
        'Gemini API key is missing. Run app with --dart-define=GEMINI_API_KEY=YOUR_KEY',
      );
    }

    final response = await client.post(
      GeminiConfig.generateContentUri(),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': GeminiConfig.apiKey,
      },
      body: jsonEncode(
        _buildRequestBody(
          systemPrompt: systemPrompt,
          recentMessages: recentMessages,
          currentMessage: currentMessage,
        ),
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gemini request failed: ${response.statusCode} ${response.body}',
      );
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

    final candidates = responseJson['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini response has no candidates.');
    }

    final firstCandidate = candidates.first as Map<String, dynamic>;

    final finishReason = firstCandidate['finishReason'] as String?;

    if (finishReason != null && finishReason != 'STOP') {
      throw Exception('Gemini response did not finish normally: $finishReason');
    }

    final content = firstCandidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;

    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini response has no content parts.');
    }

    final firstPart = parts.first as Map<String, dynamic>;
    final text = firstPart['text'] as String?;

    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini response text is empty.');
    }

    final aiJson = jsonDecode(text) as Map<String, dynamic>;

    return _parseAiReply(aiJson);
  }

  Map<String, dynamic> _buildRequestBody({
    required String systemPrompt,
    required List<MessageEntity> recentMessages,
    required String currentMessage,
  }) {
    final contents = <Map<String, dynamic>>[];

    for (final message in recentMessages.take(12)) {
      contents.add({
        'role': message.sender == MessageSender.user ? 'user' : 'model',
        'parts': [
          {'text': message.text},
        ],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': currentMessage},
      ],
    });

    return {
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1000,
        'thinkingConfig': {'thinkingLevel': 'minimal'},
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'object',
          'properties': {
            'reply': {'type': 'string'},
            'emotion': {
              'type': 'string',
              'enum': [
                'neutral',
                'happy',
                'sad',
                'confused',
                'excited',
                'encouraging',
              ],
            },
            'memoryCandidate': {
              'type': 'object',
              'properties': {
                'shouldSave': {'type': 'boolean'},
                'text': {'type': 'string'},
                'category': {
                  'type': 'string',
                  'enum': [
                    'preference',
                    'project',
                    'learning_level',
                    'goal',
                    'personal_context',
                    'none',
                  ],
                },
                'importance': {'type': 'integer'},
              },
              'required': ['shouldSave', 'text', 'category', 'importance'],
            },
          },
          'required': ['reply', 'emotion', 'memoryCandidate'],
        },
      },
    };
  }

  AiReplyEntity _parseAiReply(Map<String, dynamic> json) {
    final memoryJson = json['memoryCandidate'] as Map<String, dynamic>?;

    return AiReplyEntity(
      reply: json['reply'] as String? ?? '',
      emotion: json['emotion'] as String? ?? 'neutral',
      memoryCandidate: MemoryCandidateEntity(
        shouldSave: memoryJson?['shouldSave'] as bool? ?? false,
        text: memoryJson?['text'] as String? ?? '',
        category: _parseMemoryCategory(memoryJson?['category'] as String?),
        importance: memoryJson?['importance'] as int? ?? 0,
      ),
    );
  }

  MemoryCategory _parseMemoryCategory(String? value) {
    return switch (value) {
      'preference' => MemoryCategory.preference,
      'project' => MemoryCategory.project,
      'learning_level' => MemoryCategory.learningLevel,
      'goal' => MemoryCategory.goal,
      'personal_context' => MemoryCategory.personalContext,
      _ => MemoryCategory.none,
    };
  }
}

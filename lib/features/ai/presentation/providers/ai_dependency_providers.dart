import 'package:ai_buddy/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:ai_buddy/features/ai/data/datasources/gemini_ai_datasource.dart';
import 'package:ai_buddy/features/ai/data/datasources/gemini_config.dart';
import 'package:ai_buddy/features/ai/data/datasources/mock_ai_datasource.dart';
import 'package:ai_buddy/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:ai_buddy/features/ai/domain/repositories/ai_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();

  ref.onDispose(client.close);

  return client;
});

final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) {
  if (!GeminiConfig.hasApiKey) {
    debugPrint('Using MockAiDataSource');
    return const MockAiDataSource();
  }

  debugPrint('Using GeminiAiDataSource');

  return GeminiAiDataSource(client: ref.watch(httpClientProvider));
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(
    remoteDataSource: ref.watch(aiRemoteDataSourceProvider),
  );
});

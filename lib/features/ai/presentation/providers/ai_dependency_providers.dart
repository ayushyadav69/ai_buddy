import 'package:ai_buddy/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:ai_buddy/features/ai/data/datasources/mock_ai_datasource.dart';
import 'package:ai_buddy/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:ai_buddy/features/ai/domain/repositories/ai_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) {
  return const MockAiDataSource();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(
    remoteDataSource: ref.watch(aiRemoteDataSourceProvider),
  );
});

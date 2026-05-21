import 'package:ai_buddy/features/friends/domain/usecases/generate_friend_prompt_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenerateFriendPromptUseCase', () {
    test('should generate prompt using friend persona details', () {
      const useCase = GenerateFriendPromptUseCase();

      final prompt = useCase.execute(
        name: 'Code Buddy',
        role: 'Flutter mentor',
        goal: 'Help the user learn Flutter step by step',
        personality: 'Friendly, patient, practical',
        tone: 'Simple and beginner-friendly',
        responseStyle: 'Explain with small examples',
        boundaries: 'Do not overcomplicate answers.',
      );

      expect(prompt, contains('You are Code Buddy.'));
      expect(prompt, contains('Role: Flutter mentor'));
      expect(
        prompt,
        contains('Goal: Help the user learn Flutter step by step'),
      );
      expect(prompt, contains('Personality: Friendly, patient, practical'));
      expect(prompt, contains('Tone: Simple and beginner-friendly'));
      expect(prompt, contains('Response Style: Explain with small examples'));
      expect(prompt, contains('Do not overcomplicate answers.'));
      expect(prompt, contains('Return only valid JSON'));
    });
  });
}

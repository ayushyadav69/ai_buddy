import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_state_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final buddyStateControllerProvider =
    NotifierProvider<BuddyStateController, BuddyUiState>(
      BuddyStateController.new,
    );

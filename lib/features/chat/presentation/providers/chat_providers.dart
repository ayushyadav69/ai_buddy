import 'package:ai_buddy/features/chat/presentation/viewmodels/chat_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(
  ChatViewModel.new,
);

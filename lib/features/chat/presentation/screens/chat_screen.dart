import 'package:ai_buddy/core/constants/app_constants.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_providers.dart';
import 'package:ai_buddy/features/buddy/presentation/widgets/buddy_stage.dart';
import 'package:ai_buddy/features/chat/presentation/viewmodels/chat_viewmodel.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String friendId;
  final String friendName;

  const ChatScreen({
    required this.friendId,
    required this.friendName,
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(chatViewModelProvider.notifier)
          .loadOrCreateChat(
            userId: AppConstants.devUserId,
            friendId: widget.friendId,
            friendName: widget.friendName,
          );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    _messageController.clear();

    final buddyController = ref.read(buddyStateControllerProvider.notifier);

    buddyController.setThinking();

    final buddyMessage = await ref
        .read(chatViewModelProvider.notifier)
        .sendTextMessage(
          userId: AppConstants.devUserId,
          friendId: widget.friendId,
          text: text,
        );

    if (!mounted) {
      return;
    }

    if (buddyMessage == null) {
      buddyController.setIdle();
      return;
    }

    buddyController.setTalking(
      reply: buddyMessage.text,
      emotion: buddyMessage.emotion ?? 'neutral',
    );

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    buddyController.setIdle();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    ref.listen<ChatState>(chatViewModelProvider, (previous, next) {
      final errorMessage = next.errorMessage;

      if (errorMessage == null || errorMessage == previous?.errorMessage) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    });
    final buddyState = ref.watch(buddyStateControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.friendName)),
      body: Column(
        children: [
          BuddyStage(friendName: widget.friendName, state: buddyState),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Say hello.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];

                    return _MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Message your buddy...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: state.isSending ? null : _sendMessage,
                    icon: state.isSending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message.text),
      ),
    );
  }
}

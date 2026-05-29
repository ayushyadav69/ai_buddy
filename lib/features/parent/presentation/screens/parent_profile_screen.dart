import 'package:ai_buddy/features/buddy/domain/entities/buddy_definition.dart';
import 'package:ai_buddy/features/buddy/domain/entities/default_buddies.dart';
import 'package:ai_buddy/features/buddy/presentation/theme/buddy_visual_theme.dart';
import 'package:ai_buddy/features/chat/domain/entities/message_entity.dart';
import 'package:ai_buddy/features/chat/presentation/providers/chat_dependency_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buddies = DefaultBuddies.all;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F0FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Parent Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: buddies.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _ParentIntroCard();
            }

            final buddy = buddies[index - 1];

            return _BuddyHistoryTile(
              buddy: buddy,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BuddyHistoryDetailScreen(buddy: buddy),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ParentIntroCard extends StatelessWidget {
  const _ParentIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFFFF7AC8)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.family_restroom_rounded,
              color: Colors.deepPurple,
              size: 30,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversation History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Review what your child asked each buddy.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuddyHistoryTile extends ConsumerWidget {
  final BuddyDefinition buddy;
  final VoidCallback onTap;

  const _BuddyHistoryTile({required this.buddy, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visualTheme = buddy.visualTheme;
    final chatRepository = ref.watch(chatRepositoryProvider);

    return FutureBuilder<List<MessageEntity>>(
      future: chatRepository.getMessages(chatId: 'room-${buddy.id}'),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? const [];
        final lastMessage = messages.isEmpty ? null : messages.last;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: visualTheme.primaryColor.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: visualTheme.softColor,
                  child: Icon(
                    visualTheme.icon,
                    color: visualTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buddy.name,
                        style: TextStyle(
                          color: visualTheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage == null
                            ? 'No conversation yet'
                            : _previewText(lastMessage),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13.5,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      '${messages.length}',
                      style: TextStyle(
                        color: visualTheme.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'msgs',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: visualTheme.primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _previewText(MessageEntity message) {
    final prefix = message.sender == MessageSender.user ? 'Child' : 'Buddy';
    return '$prefix: ${message.text}';
  }
}

class BuddyHistoryDetailScreen extends ConsumerWidget {
  final BuddyDefinition buddy;

  const BuddyHistoryDetailScreen({required this.buddy, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visualTheme = buddy.visualTheme;
    final chatRepository = ref.watch(chatRepositoryProvider);

    return Scaffold(
      backgroundColor: visualTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: visualTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${buddy.name} History',
          style: TextStyle(
            color: visualTheme.primaryColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<MessageEntity>>(
          future: chatRepository.getMessages(chatId: 'room-${buddy.id}'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final messages = snapshot.data ?? const [];

            if (messages.isEmpty) {
              return _EmptyHistoryState(visualTheme: visualTheme);
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final message = messages[index];

                return _HistoryMessageBubble(
                  message: message,
                  visualTheme: visualTheme,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  final BuddyVisualTheme visualTheme;

  const _EmptyHistoryState({required this.visualTheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              color: visualTheme.primaryColor,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              'No history yet',
              style: TextStyle(
                color: visualTheme.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'When your child talks with this buddy, messages will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMessageBubble extends StatelessWidget {
  final MessageEntity message;
  final BuddyVisualTheme visualTheme;

  const _HistoryMessageBubble({
    required this.message,
    required this.visualTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isChild = message.sender == MessageSender.user;

    return Align(
      alignment: isChild ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
        decoration: BoxDecoration(
          color: isChild ? visualTheme.softColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isChild ? 24 : 8),
            bottomRight: Radius.circular(isChild ? 8 : 24),
          ),
          border: Border.all(
            color: visualTheme.primaryColor.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          crossAxisAlignment: isChild
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              isChild ? 'Child' : 'Buddy',
              style: TextStyle(
                color: isChild ? visualTheme.primaryColor : Colors.deepPurple,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message.text,
              textAlign: isChild ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 15.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$day/$month $hour:$minute';
  }
}

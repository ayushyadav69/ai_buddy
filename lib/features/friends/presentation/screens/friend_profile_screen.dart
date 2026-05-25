import 'package:ai_buddy/features/friends/presentation/providers/friend_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendProfileScreen extends ConsumerStatefulWidget {
  final String friendId;

  const FriendProfileScreen({required this.friendId, super.key});

  @override
  ConsumerState<FriendProfileScreen> createState() =>
      _FriendProfileScreenState();
}

class _FriendProfileScreenState extends ConsumerState<FriendProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(friendProfileViewModelProvider.notifier)
          .loadFriend(friendId: widget.friendId);
    });
  }

  Future<void> _deleteFriend() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Buddy?'),
          content: const Text(
            'This buddy will be removed from your list. Later, SyncEngine will also delete it from remote.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await ref
        .read(friendProfileViewModelProvider.notifier)
        .deleteFriend(friendId: widget.friendId);

    final state = ref.read(friendProfileViewModelProvider);

    if (!mounted) return;

    if (state.isDeleted) {
      Navigator.of(context).pop(true);
    }

    if (state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendProfileViewModelProvider);
    final friend = state.friend;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddy Profile'),
        actions: [
          IconButton(
            onPressed: state.isDeleting ? null : _deleteFriend,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          }

          if (friend == null) {
            return const Center(child: Text('Buddy not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileItem(title: 'Name', value: friend.name),
              _ProfileItem(title: 'Role', value: friend.role),
              _ProfileItem(title: 'Goal', value: friend.goal),
              _ProfileItem(title: 'Personality', value: friend.personality),
              _ProfileItem(title: 'Tone', value: friend.tone),
              _ProfileItem(
                title: 'Response Style',
                value: friend.responseStyle,
              ),
              _ProfileItem(title: 'Boundaries', value: friend.boundaries),
              _ProfileItem(title: 'Sync Status', value: friend.syncStatus.name),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('System Prompt'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(friend.systemPrompt),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String title;
  final String value;

  const _ProfileItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(title), subtitle: Text(value)),
    );
  }
}

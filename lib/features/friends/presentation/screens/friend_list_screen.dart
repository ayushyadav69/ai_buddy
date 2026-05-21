import 'package:ai_buddy/core/constants/app_constants.dart';
import 'package:ai_buddy/features/friends/presentation/providers/friend_providers.dart';
import 'package:ai_buddy/features/friends/presentation/screens/friend_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendListScreen extends ConsumerStatefulWidget {
  const FriendListScreen({super.key});

  @override
  ConsumerState<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends ConsumerState<FriendListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(friendListViewModelProvider.notifier)
          .loadFriends(userId: AppConstants.devUserId);
    });
  }

  Future<void> _openCreateFriendScreen() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FriendFormScreen()));

    if (!mounted) return;

    ref
        .read(friendListViewModelProvider.notifier)
        .loadFriends(userId: AppConstants.devUserId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendListViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Buddies')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateFriendScreen,
        child: const Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          }

          if (state.friends.isEmpty) {
            return const Center(
              child: Text('No buddies yet. Create your first buddy.'),
            );
          }

          return ListView.separated(
            itemCount: state.friends.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final friend = state.friends[index];

              return ListTile(
                title: Text(friend.name),
                subtitle: Text(friend.role),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${friend.name} chat will open later.'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

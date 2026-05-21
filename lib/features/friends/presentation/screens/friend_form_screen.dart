import 'package:ai_buddy/core/constants/app_constants.dart';
import 'package:ai_buddy/features/friends/presentation/providers/friend_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendFormScreen extends ConsumerStatefulWidget {
  const FriendFormScreen({super.key});

  @override
  ConsumerState<FriendFormScreen> createState() => _FriendFormScreenState();
}

class _FriendFormScreenState extends ConsumerState<FriendFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _goalController = TextEditingController();
  final _personalityController = TextEditingController();
  final _toneController = TextEditingController();
  final _responseStyleController = TextEditingController();
  final _boundariesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController.text = 'Code Buddy';
    _roleController.text = 'Flutter mentor';
    _goalController.text = 'Help the user learn Flutter step by step';
    _personalityController.text = 'Friendly, patient, practical';
    _toneController.text = 'Simple and beginner-friendly';
    _responseStyleController.text = 'Explain with small examples';
    _boundariesController.text = 'Do not overcomplicate answers.';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _goalController.dispose();
    _personalityController.dispose();
    _toneController.dispose();
    _responseStyleController.dispose();
    _boundariesController.dispose();
    super.dispose();
  }

  Future<void> _createFriend() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    await ref
        .read(friendFormViewModelProvider.notifier)
        .createFriend(
          userId: AppConstants.devUserId,
          name: _nameController.text,
          role: _roleController.text,
          goal: _goalController.text,
          personality: _personalityController.text,
          tone: _toneController.text,
          responseStyle: _responseStyleController.text,
          boundaries: _boundariesController.text,
          avatarType: 'alien_basic',
          voiceType: 'default',
        );

    final state = ref.read(friendFormViewModelProvider);

    if (!mounted) return;

    if (state.savedFriend != null) {
      Navigator.of(context).pop();
    }

    if (state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendFormViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Buddy')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _FriendTextField(controller: _nameController, label: 'Name'),
                _FriendTextField(controller: _roleController, label: 'Role'),
                _FriendTextField(
                  controller: _goalController,
                  label: 'Goal',
                  maxLines: 2,
                ),
                _FriendTextField(
                  controller: _personalityController,
                  label: 'Personality',
                  maxLines: 2,
                ),
                _FriendTextField(controller: _toneController, label: 'Tone'),
                _FriendTextField(
                  controller: _responseStyleController,
                  label: 'Response Style',
                  maxLines: 2,
                ),
                _FriendTextField(
                  controller: _boundariesController,
                  label: 'Boundaries',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.isLoading ? null : _createFriend,
                    child: state.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Buddy'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _FriendTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }

          return null;
        },
      ),
    );
  }
}

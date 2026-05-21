import 'package:ai_buddy/features/friends/presentation/viewmodels/friend_form_viewmodel.dart';
import 'package:ai_buddy/features/friends/presentation/viewmodels/friend_list_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendListViewModelProvider =
    NotifierProvider<FriendListViewModel, FriendListState>(
      FriendListViewModel.new,
    );

final friendFormViewModelProvider =
    NotifierProvider<FriendFormViewModel, FriendFormState>(
      FriendFormViewModel.new,
    );

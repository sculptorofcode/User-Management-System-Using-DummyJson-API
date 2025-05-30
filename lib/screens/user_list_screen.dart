import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/theme_bloc/theme_bloc.dart';
import '../blocs/theme_bloc/theme_event.dart';
import '../blocs/theme_bloc/theme_state.dart';
import '../blocs/user_bloc/user_bloc.dart';
import '../blocs/user_bloc/user_event.dart';
import '../blocs/user_bloc/user_state.dart';
import '../widgets/search_bar.dart' as custom_widgets;
import '../widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _scrollController = ScrollController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    context.read<UserBloc>().add(FetchUsers());
  }

  void _onScroll() {
    if (_isSearching) return;

    if (_isBottom) {
      final state = context.read<UserBloc>().state;
      if (state is UserLoaded && !state.hasReachedMax) {
        context.read<UserBloc>().add(LoadMoreUsers(skip: state.users.length));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (_isSearching) {
      context.read<UserBloc>().add(SearchUsers(query));
    } else {
      context.read<UserBloc>().add(FetchUsers());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: state.isDarkMode ? 'Light Mode' : 'Dark Mode',
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleTheme());
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          custom_widgets.SearchBar(onSearch: _onSearch),
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UserLoading && _searchQuery.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UserLoaded) {
                  return _buildUserList(state);
                } else if (state is UserLoadingMore) {
                  return _buildUserList(UserLoaded(users: state.users), true);
                } else if (state is UserError) {
                  return _buildErrorWidget(state);
                } else if (state is UserRefreshing) {
                  return _buildUserList(UserLoaded(users: state.users), true);
                }
                return const Center(child: Text('No users found'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(UserLoaded state, [bool isLoading = false]) {
    if (state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSearching ? Icons.search_off : Icons.people_outline,
              size: 80,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching
                  ? 'No users found matching "$_searchQuery"'
                  : 'No users available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_isSearching)
              TextButton.icon(
                onPressed: () {
                  _onSearch('');
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Search'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserBloc>().add(RefreshUsers());
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount:
            state.users.length + (isLoading || !state.hasReachedMax ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.users.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            );
          }

          return UserCard(user: state.users[index], index: index);
        },
      ),
    );
  }

  Widget _buildErrorWidget(UserError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Error: ${state.message}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

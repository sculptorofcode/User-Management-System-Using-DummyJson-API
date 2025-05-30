import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    on<FetchUsers>((event, emit) async {
      emit(UserLoading());
      // try {
      final result = await userRepository.fetchUsers(event.limit, event.skip);
      debugPrint(
        'UserBloc: Fetched ${result.users.length} users, total: ${result.total}',
      );
      emit(
        UserLoaded(
          users: result.users,
          totalUsers: result.total,
          hasReachedMax: result.users.length >= result.total,
          currentPage: 0,
        ),
      );
      // } catch (e) {
      //   debugPrint('UserBloc: Error fetching users: ${e.toString()}');
      //   emit(UserError(e.toString()));
      // }
    });
    on<SearchUsers>((event, emit) async {
      if (event.query.isEmpty) {
        add(FetchUsers());
        return;
      }

      final currentState = state;
      if (currentState is UserLoaded) {
        emit(UserSearching(currentState.users));
      } else {
        emit(UserLoading());
      }

      try {
        final result = await userRepository.searchUsers(event.query);
        emit(
          UserLoaded(
            users: result.users,
            totalUsers: result.total,
            hasReachedMax: true,
            // No pagination for search results
            currentPage: 0,
            isSearchResult: true,
            searchQuery: event.query,
          ),
        );
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<LoadMoreUsers>((event, emit) async {
      final currentState = state;

      if (currentState is UserLoaded && !currentState.hasReachedMax) {
        emit(UserLoadingMore(currentState.users, currentState.currentPage));
        try {
          final nextPage = currentState.currentPage + 1;
          final result = await userRepository.fetchUsers(
            event.limit,
            event.skip + currentState.users.length,
          );

          final allUsers = [...currentState.users, ...result.users];

          emit(
            UserLoaded(
              users: allUsers,
              hasReachedMax: allUsers.length >= result.total,
              totalUsers: result.total,
              currentPage: nextPage,
            ),
          );
        } catch (e) {
          emit(
            UserLoaded(
              users: currentState.users,
              hasReachedMax: currentState.hasReachedMax,
              totalUsers: currentState.totalUsers,
              currentPage: currentState.currentPage,
            ),
          );
        }
      }
    });

    on<RefreshUsers>((event, emit) async {
      final currentState = state;
      if (currentState is UserLoaded) {
        emit(UserRefreshing(currentState.users));
        try {
          final result = await userRepository.fetchUsers(10, 0);
          emit(
            UserLoaded(
              users: result.users,
              totalUsers: result.total,
              hasReachedMax: result.users.length >= result.total,
              currentPage: 0,
            ),
          );
        } catch (e) {
          emit(UserError(e.toString()));
        }
      }
    });
  }
}

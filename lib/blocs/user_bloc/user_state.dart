import 'package:equatable/equatable.dart';

import '../../models/user.dart';

abstract class UserState extends Equatable {
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserRefreshing extends UserState {
  final List<User> users;

  UserRefreshing(this.users);

  @override
  List<Object> get props => [users];
}

class UserLoadingMore extends UserState {
  final List<User> users;
  final int currentPage;

  UserLoadingMore(this.users, this.currentPage);

  @override
  List<Object> get props => [users, currentPage];
}

class UserSearching extends UserState {
  final List<User> currentUsers;

  UserSearching(this.currentUsers);

  @override
  List<Object> get props => [currentUsers];
}

class UserLoaded extends UserState {
  final List<User> users;
  final bool hasReachedMax;
  final int totalUsers;
  final int currentPage;
  final bool isSearchResult;
  final String searchQuery;

  UserLoaded({
    required this.users,
    this.hasReachedMax = false,
    this.totalUsers = 0,
    this.currentPage = 0,
    this.isSearchResult = false,
    this.searchQuery = '',
  });

  UserLoaded copyWith({
    List<User>? users,
    bool? hasReachedMax,
    int? totalUsers,
    int? currentPage,
    bool? isSearchResult,
    String? searchQuery,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalUsers: totalUsers ?? this.totalUsers,
      currentPage: currentPage ?? this.currentPage,
      isSearchResult: isSearchResult ?? this.isSearchResult,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [
    users,
    hasReachedMax,
    totalUsers,
    currentPage,
    isSearchResult,
    searchQuery,
  ];
}

class UserError extends UserState {
  final String message;

  UserError(this.message);

  @override
  List<Object> get props => [message];
}

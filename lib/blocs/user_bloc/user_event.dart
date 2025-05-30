import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUsers extends UserEvent {
  final int limit;
  final int skip;

  FetchUsers({this.limit = 10, this.skip = 0});

  @override
  List<Object> get props => [limit, skip];
}

class SearchUsers extends UserEvent {
  final String query;

  SearchUsers(this.query);

  @override
  List<Object> get props => [query];
}

class LoadMoreUsers extends UserEvent {
  final int limit;
  final int skip;

  LoadMoreUsers({this.limit = 10, this.skip = 0});

  @override
  List<Object> get props => [limit, skip];
}

class RefreshUsers extends UserEvent {}

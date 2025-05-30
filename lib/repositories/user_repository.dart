import '../models/user.dart';
import '../utils/api_client.dart';

class UserPaginationResult {
  final List<User> users;
  final int total;
  final int limit;
  final int skip;

  UserPaginationResult({
    required this.users,
    required this.total,
    required this.limit,
    required this.skip,
  });
}

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

  Future<UserPaginationResult> fetchUsers(int limit, int skip) async {
    final data = await apiClient.fetchUsers(limit: limit, skip: skip);

    final users =
        (data['users'] as List).map((user) => User.fromJson(user)).toList();

    return UserPaginationResult(
      users: users,
      total: data['total'] ?? 0,
      limit: data['limit'] ?? limit,
      skip: data['skip'] ?? skip,
    );
  }

  Future<UserPaginationResult> searchUsers(String query) async {
    final data = await apiClient.searchUsers(query);

    final users =
        (data['users'] as List).map((user) => User.fromJson(user)).toList();

    return UserPaginationResult(
      users: users,
      total: data['total'] ?? 0,
      limit: data['limit'] ?? 0,
      skip: data['skip'] ?? 0,
    );
  }
}

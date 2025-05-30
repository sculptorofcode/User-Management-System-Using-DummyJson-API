import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl = 'https://dummyjson.com';

  Future<Map<String, dynamic>> fetchUsers({
    int limit = 10,
    int skip = 0,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users?limit=$limit&skip=$skip'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      debugPrint(
        'Error fetching users: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Failed to load users');
    }
  }

  Future<Map<String, dynamic>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?q=${Uri.encodeComponent(query)}'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      debugPrint(
        'Error searching users: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Failed to search users');
    }
  }

  Future<List<dynamic>> fetchUserPosts(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/user/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['posts'];
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<dynamic>> fetchUserTodos(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/todos/user/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['todos'];
    } else {
      throw Exception('Failed to load todos');
    }
  }
}

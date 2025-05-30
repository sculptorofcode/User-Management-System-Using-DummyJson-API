import 'package:hive/hive.dart';

import '../utils/api_client.dart';

class PostRepository {
  final ApiClient apiClient;
  static const String _postBoxName = 'postsBox';

  PostRepository(this.apiClient);

  Future<void> initRepository() async {
    // We don't need to register the adapter if we're just storing JSON
    if (!Hive.isBoxOpen(_postBoxName)) {
      await Hive.openBox<Map>(_postBoxName);
    }
  }

  Future<List<Map>> getUserPosts(int userId) async {
    try {
      // Get remote posts
      final remotePostsData = await apiClient.fetchUserPosts(userId);
      final remotePosts =
          remotePostsData
              .map((data) => {...data, 'userId': userId, 'isLocal': false})
              .toList();

      // Get local posts
      final localPosts = await getLocalPosts(userId);

      // Combine and sort posts (local posts first, then API posts)
      final allPosts = [...localPosts, ...remotePosts];
      return allPosts;
    } catch (e) {
      // If API fails, return only local posts
      return await getLocalPosts(userId);
    }
  }

  Future<List<Map<String, dynamic>>> getLocalPosts(int userId) async {
    try {
      final box = await Hive.openBox<Map>(_postBoxName);
      final allPosts = box.values.toList();

      // Filter posts for the specific user
      final userPosts =
          allPosts
              .where((post) => post['userId'] == userId)
              .map(
                (post) => {...Map<String, dynamic>.from(post), 'isLocal': true},
              )
              .toList();

      return userPosts;
    } catch (e) {
      print('Error getting local posts: $e');
      return [];
    }
  }

  Future<bool> addPost(Map<String, dynamic> postData) async {
    try {
      final box = await Hive.openBox<Map>(_postBoxName);

      // Generate a unique local ID (negative to avoid collision with API IDs)
      final maxId =
          box.values.isEmpty
              ? 0
              : box.values
                  .map((post) => post['id'] is int ? post['id'] : 0)
                  .reduce((max, id) => id < 0 && id < max ? id : max);

      final newId = maxId < 0 ? maxId - 1 : -1;
      final userId = postData['userId'];

      final post = {
        'id': newId,
        'title': postData['title'],
        'body': postData['body'],
        'userId': userId,
        'isLocal': true,
      };

      // Add to Hive box
      await box.add(post);
      return true;
    } catch (e) {
      print('Error adding post: $e');
      return false;
    }
  }

  Future<bool> deleteLocalPost(int postId) async {
    try {
      final box = await Hive.openBox<Map>(_postBoxName);

      // Find the post with the given ID
      final keys = box.keys.toList();
      int? foundKey;
      for (var key in keys) {
        final value = box.get(key);
        if (value != null && value['id'] == postId) {
          foundKey = key;
          break;
        }
      }

      if (foundKey != null) {
        await box.delete(foundKey);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }
}

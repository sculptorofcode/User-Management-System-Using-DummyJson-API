import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Post {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final int userId;

  @HiveField(4)
  final bool isLocal;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.isLocal = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      userId: json['userId'] ?? 0,
      isLocal: json['isLocal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
      'isLocal': isLocal,
    };
  }
}

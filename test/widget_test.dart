// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:user/main.dart';
import 'package:user/repositories/post_repository.dart';
import 'package:user/repositories/user_repository.dart';
import 'package:user/utils/api_client.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Replace with a valid Box<dynamic> instance, for example using a mock or a fake for testing.
    // Example using a simple in-memory box from hive (if using Hive for Box):
    final box = await Hive.openBox('testBox');
    final apiClient = ApiClient();
    final userRepository = UserRepository(apiClient);
    final postRepository = PostRepository(apiClient);
    await postRepository.initRepository();
    await tester.pumpWidget(
      MyApp(
        themeBox: box,
        userRepository: userRepository,
        postRepository: postRepository,
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

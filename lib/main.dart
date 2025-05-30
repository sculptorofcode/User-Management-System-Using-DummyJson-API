import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'blocs/theme_bloc/theme_bloc.dart';
import 'blocs/theme_bloc/theme_event.dart';
import 'blocs/theme_bloc/theme_state.dart';
import 'blocs/user_bloc/user_bloc.dart';
import 'repositories/post_repository.dart';
import 'repositories/user_repository.dart';
import 'screens/user_list_screen.dart';
import 'utils/api_client.dart';
import 'utils/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  try {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
  } catch (e) {
    // Fallback to default path if permission is denied
    await Hive.initFlutter();
    print('Error accessing documents directory: $e');
  }
  // Open the theme box
  final themeBox = await Hive.openBox('themeBox');

  // Initialize API client and repositories
  final apiClient = ApiClient();
  final userRepository = UserRepository(apiClient);
  final postRepository = PostRepository(apiClient);
  await postRepository.initRepository();

  runApp(
    MyApp(
      themeBox: themeBox,
      userRepository: userRepository,
      postRepository: postRepository,
    ),
  );
}

class MyApp extends StatefulWidget {
  final Box themeBox;
  final UserRepository userRepository;
  final PostRepository postRepository;

  const MyApp({
    super.key,
    required this.themeBox,
    required this.userRepository,
    required this.postRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // We'll request permissions when we have a context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only request if we have a valid context
      if (mounted) {
        try {
          PermissionService.requestStoragePermission(context).catchError((
            error,
          ) {
            print('Error requesting permissions: $error');
            // Continue app flow even if permission request fails
            return true; // Mark error as handled
          });
        } catch (e) {
          print('Exception during permission check: $e');
          // Continue app flow even if permission check fails
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.userRepository),
        RepositoryProvider.value(value: widget.postRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => ThemeBloc(widget.themeBox)..add(InitializeTheme()),
          ),
          BlocProvider(create: (context) => UserBloc(widget.userRepository)),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'User Management App',
              debugShowCheckedModeBanner: false,
              theme: themeState.themeData,
              home: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: const UserListScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/following_provider.dart';
import 'routes.dart';
import 'services/github_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SharedPreferencesStorageService();
  final authProvider = AuthProvider(storage);

  await authProvider.restoreSession();

  runApp(GitSearchApp(authProvider: authProvider));
}

class GitSearchApp extends StatelessWidget {
  final AuthProvider authProvider;

  const GitSearchApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<GitHubService>(
          create: (_) => GitHubService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => FollowingProvider()),
      ],
      child: MaterialApp(
        title: 'GitSearch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        initialRoute: authProvider.isLoggedIn
            ? AppRoutes.catalog
            : AppRoutes.login,
        onGenerateInitialRoutes: (routeName) => [
          MaterialPageRoute(
            settings: RouteSettings(name: routeName),
            builder: AppRoutes.routes[routeName]!,
          ),
        ],
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

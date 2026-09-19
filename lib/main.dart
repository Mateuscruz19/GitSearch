import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/following_provider.dart';
import 'providers/viewed_provider.dart';
import 'routes.dart';
import 'services/github_service.dart';
import 'services/storage_service.dart';
import 'providers/search_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SharedPreferencesStorageService();
  final authProvider = AuthProvider(storage);
  final favoritesProvider = FavoritesProvider(storage);
  final followingProvider = FollowingProvider(storage);
  final viewedProvider = ViewedProvider(storage);

  await authProvider.restoreSession();

  // Favorites, following and viewed belong to the logged-in user, so they
  // are reloaded whenever someone logs in or out.
  var loadedUsername = authProvider.username;
  Future<void> loadUserData() => Future.wait([
    favoritesProvider.load(loadedUsername),
    followingProvider.load(loadedUsername),
    viewedProvider.load(loadedUsername),
  ]);

  await loadUserData();
  authProvider.addListener(() {
    if (authProvider.username == loadedUsername) return;
    loadedUsername = authProvider.username;
    loadUserData();
  });

  runApp(
    GitSearchApp(
      authProvider: authProvider,
      favoritesProvider: favoritesProvider,
      followingProvider: followingProvider,
      viewedProvider: viewedProvider,
    ),
  );
}

class GitSearchApp extends StatelessWidget {
  final AuthProvider authProvider;
  final FavoritesProvider favoritesProvider;
  final FollowingProvider followingProvider;
  final ViewedProvider viewedProvider;

  const GitSearchApp({
    super.key,
    required this.authProvider,
    required this.favoritesProvider,
    required this.followingProvider,
    required this.viewedProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<GitHubService>(
          create: (_) => GitHubService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: followingProvider),
        ChangeNotifierProvider.value(value: viewedProvider),
        ChangeNotifierProvider(create: (ctx) => SearchProvider(ctx.read<GitHubService>())),
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

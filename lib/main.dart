import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/following_provider.dart';
import 'routes.dart';
import 'services/github_service.dart';

void main() {
  runApp(const GitSearchApp());
}

class GitSearchApp extends StatelessWidget {
  const GitSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<GitHubService>(
          create: (_) => GitHubService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

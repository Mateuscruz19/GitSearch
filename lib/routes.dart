import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/details_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/following_screen.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/viewed_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String catalog = '/catalog';
  static const String search = '/search';
  static const String details = '/details';
  static const String favorites = '/favorites';
  static const String following = '/following';
  static const String viewed = '/viewed';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    catalog: (_) => const HomeShell(),
    search: (_) => const SearchScreen(),
    favorites: (_) => const FavoritesScreen(),
    following: (_) => const FollowingScreen(),
    viewed: (_) => const ViewedScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == details) {
      final login = settings.arguments as String;
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => DetailsScreen(login: login),
      );
    }
    return null;
  }
}

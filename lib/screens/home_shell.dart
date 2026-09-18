import 'package:flutter/material.dart';

import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'following_screen.dart';
import 'viewed_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    CatalogScreen(),
    FavoritesScreen(),
    FollowingScreen(),
    ViewedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Catalog'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Following'),
          NavigationDestination(icon: Icon(Icons.visibility_outlined), label: 'Viewed'),
        ],
      ),
    );
  }
}

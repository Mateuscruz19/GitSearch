import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsearch/models/github_user.dart';
import 'package:gitsearch/providers/favorites_provider.dart';
import 'package:gitsearch/providers/viewed_provider.dart';
import 'package:gitsearch/screens/favorites_screen.dart';
import 'package:gitsearch/screens/viewed_screen.dart';
import 'package:gitsearch/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MemoryStorage implements StorageService {
  final Map<String, Object> values = {};

  @override
  Future<Object?> loadJson(String key) async => values[key];

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> saveJson(String key, Object value) async {
    values[key] = value;
  }
}

const user = GitHubUser(
  id: 1,
  login: 'octocat',
  avatarUrl: 'https://example.com/avatar.png',
  htmlUrl: 'https://github.com/octocat',
);

const otherUser = GitHubUser(
  id: 2,
  login: 'monalisa',
  avatarUrl: 'https://example.com/avatar2.png',
  htmlUrl: 'https://github.com/monalisa',
);

Widget _wrap(Widget child, {required List<SingleChildWidget> providers}) {
  return MultiProvider(
    providers: providers,
    child: MaterialApp(home: child),
  );
}

void main() {
  test('toggles favorites and persists them', () async {
    final storage = MemoryStorage();
    final favorites = FavoritesProvider(storage);

    await favorites.load();
    expect(favorites.isFavorite(user), isFalse);

    await favorites.toggle(user);
    expect(favorites.isFavorite(user), isTrue);

    final restored = FavoritesProvider(storage);
    await restored.load();
    expect(restored.isFavorite(user), isTrue);

    await favorites.toggle(user);
    expect(favorites.isFavorite(user), isFalse);
  });

  test('marks users as viewed, most recent first, and persists them', () async {
    final storage = MemoryStorage();
    final viewed = ViewedProvider(storage);

    await viewed.load();
    expect(viewed.isViewed(user), isFalse);

    await viewed.markViewed(user);
    await viewed.markViewed(otherUser);
    expect(viewed.viewed.map((u) => u.login), ['monalisa', 'octocat']);

    await viewed.markViewed(user);
    expect(viewed.viewed.map((u) => u.login), ['octocat', 'monalisa']);

    final restored = ViewedProvider(storage);
    await restored.load();
    expect(restored.isViewed(user), isTrue);
    expect(restored.isViewed(otherUser), isTrue);
  });

  testWidgets('favorites screen updates automatically when a favorite is toggled', (
    tester,
  ) async {
    final favorites = FavoritesProvider(MemoryStorage());
    await favorites.load();

    await tester.pumpWidget(
      _wrap(
        const FavoritesScreen(),
        providers: [ChangeNotifierProvider.value(value: favorites)],
      ),
    );

    expect(find.text('No favorites yet'), findsOneWidget);

    await favorites.toggle(user);
    await tester.pump();

    expect(find.text('No favorites yet'), findsNothing);
    expect(find.text('octocat'), findsOneWidget);
  });

  testWidgets('viewed screen updates automatically when a profile is viewed', (
    tester,
  ) async {
    final viewed = ViewedProvider(MemoryStorage());
    final favorites = FavoritesProvider(MemoryStorage());
    await viewed.load();
    await favorites.load();

    await tester.pumpWidget(
      _wrap(
        const ViewedScreen(),
        providers: [
          ChangeNotifierProvider.value(value: viewed),
          ChangeNotifierProvider.value(value: favorites),
        ],
      ),
    );

    expect(find.text('No viewed profiles yet'), findsOneWidget);

    await viewed.markViewed(user);
    await tester.pump();

    expect(find.text('No viewed profiles yet'), findsNothing);
    expect(find.text('octocat'), findsOneWidget);
  });
}

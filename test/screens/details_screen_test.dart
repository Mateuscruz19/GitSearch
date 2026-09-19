import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsearch/providers/favorites_provider.dart';
import 'package:gitsearch/providers/following_provider.dart';
import 'package:gitsearch/screens/details_screen.dart';
import 'package:gitsearch/services/github_service.dart';
import 'package:gitsearch/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

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

const userJson = {
  'id': 1,
  'login': 'octocat',
  'avatar_url': 'https://example.com/avatar.png',
  'html_url': 'https://github.com/octocat',
  'name': 'The Octocat',
  'bio': 'Mascote do GitHub',
  'location': 'San Francisco',
  'followers': 15200,
  'following': 9,
  'public_repos': 8,
};

const repoJson = {
  'id': 10,
  'name': 'hello-world',
  'full_name': 'octocat/hello-world',
  'html_url': 'https://github.com/octocat/hello-world',
  'description': 'Meu primeiro repositorio',
  'language': 'Dart',
  'stargazers_count': 42,
  'forks_count': 7,
  'created_at': '2024-01-02T00:00:00Z',
  'updated_at': '2026-09-10T00:00:00Z',
  'pushed_at': '2026-09-10T00:00:00Z',
};

GitHubService serviceWith(Map<String, Object> byPath) {
  return GitHubService(
    client: MockClient((request) async {
      final body = byPath[request.url.path];
      if (body == null) {
        return http.Response(jsonEncode({'message': 'Not Found'}), 404);
      }
      return http.Response(jsonEncode(body), 200);
    }),
  );
}

Future<void> pumpDetails(
  WidgetTester tester,
  GitHubService service, {
  FavoritesProvider? favorites,
  FollowingProvider? following,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<GitHubService>.value(value: service),
        ChangeNotifierProvider.value(
          value: favorites ?? FavoritesProvider(MemoryStorage()),
        ),
        ChangeNotifierProvider.value(
          value: following ?? FollowingProvider(MemoryStorage()),
        ),
      ],
      child: const MaterialApp(home: DetailsScreen(login: 'octocat')),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the profile and its repositories', (tester) async {
    await pumpDetails(
      tester,
      serviceWith({
        '/users/octocat': userJson,
        '/users/octocat/repos': [repoJson],
      }),
    );

    expect(find.text('The Octocat'), findsOneWidget);
    expect(find.text('@octocat'), findsOneWidget);
    expect(find.text('Mascote do GitHub'), findsOneWidget);
    expect(find.text('San Francisco'), findsOneWidget);

    expect(find.text('15.2k'), findsOneWidget);
    expect(find.text('Followers'), findsOneWidget);

    expect(find.text('hello-world'), findsOneWidget);
    expect(find.text('Meu primeiro repositorio'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.textContaining('/09/2026'), findsOneWidget);

    expect(find.text('No more repositories'), findsOneWidget);
  });

  testWidgets('favoriting from the details screen updates the provider', (
    tester,
  ) async {
    final favorites = FavoritesProvider(MemoryStorage());
    await favorites.load();

    await pumpDetails(
      tester,
      serviceWith({
        '/users/octocat': userJson,
        '/users/octocat/repos': <Object>[],
      }),
      favorites: favorites,
    );

    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('No public repositories'), findsOneWidget);

    await tester.tap(find.text('Favorite'));
    await tester.pumpAndSettle();

    expect(find.text('Favorited'), findsOneWidget);
    expect(favorites.favorites.single.login, 'octocat');
  });

  testWidgets('following from the details screen updates the provider', (
    tester,
  ) async {
    final following = FollowingProvider(MemoryStorage());
    await following.load();

    await pumpDetails(
      tester,
      serviceWith({
        '/users/octocat': userJson,
        '/users/octocat/repos': <Object>[],
      }),
      following: following,
    );

    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();

    expect(find.text('Unfollow'), findsOneWidget);
    expect(following.following.single.login, 'octocat');
  });

  testWidgets('shows an error with retry when the profile fails', (
    tester,
  ) async {
    await pumpDetails(tester, serviceWith({}));

    expect(find.text('Not found'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}

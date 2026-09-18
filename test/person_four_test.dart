import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsearch/models/github_user.dart';
import 'package:gitsearch/providers/auth_provider.dart';
import 'package:gitsearch/providers/favorites_provider.dart';
import 'package:gitsearch/providers/following_provider.dart';
import 'package:gitsearch/screens/login_screen.dart';
import 'package:gitsearch/services/storage_service.dart';
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

const user = GitHubUser(
  id: 1,
  login: 'octocat',
  avatarUrl: 'https://example.com/avatar.png',
  htmlUrl: 'https://github.com/octocat',
);

void main() {
  test('registers a local account and restores its session', () async {
    final storage = MemoryStorage();
    final auth = AuthProvider(storage);

    expect(await auth.register(' Octocat ', 'secret1'), isNull);
    expect(auth.username, 'octocat');
    expect(storage.values['auth_session'], 'octocat');

    final users = storage.values['auth_users']! as Map<String, String>;
    expect(users['octocat'], isNot('secret1'));

    final restoredAuth = AuthProvider(storage);
    await restoredAuth.restoreSession();
    expect(restoredAuth.isLoggedIn, isTrue);
    expect(restoredAuth.username, 'octocat');
  });

  test('rejects a wrong password and removes the session on logout', () async {
    final storage = MemoryStorage();
    final auth = AuthProvider(storage);
    await auth.register('octocat', 'secret1');
    await auth.logout();

    expect(await auth.login('octocat', 'wrong99'), isNotNull);
    expect(auth.isLoggedIn, isFalse);
    expect(await auth.login('octocat', 'secret1'), isNull);
    expect(auth.isLoggedIn, isTrue);

    await auth.logout();
    expect(storage.values.containsKey('auth_session'), isFalse);
  });

  test('restores favorites and followed users', () async {
    final storage = MemoryStorage();
    final favorites = FavoritesProvider(storage);
    final following = FollowingProvider(storage);

    await favorites.toggle(user);
    await following.toggle(user);

    final restoredFavorites = FavoritesProvider(storage);
    final restoredFollowing = FollowingProvider(storage);
    await restoredFavorites.load();
    await restoredFollowing.load();

    expect(restoredFavorites.isFavorite(user), isTrue);
    expect(restoredFollowing.isFollowing(user), isTrue);
  });

  testWidgets('login remains usable with larger text', (tester) async {
    final auth = AuthProvider(MemoryStorage());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: LoginScreen(),
          ),
        ),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password fields remain editable after registration errors', (
    tester,
  ) async {
    final auth = AuthProvider(MemoryStorage());
    await auth.register('existinguser', 'secret1');
    await auth.logout();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.tap(find.widgetWithText(TextButton, 'Create a local account'));
    await tester.pump();

    var fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'existinguser');
    await tester.enterText(fields.at(1), 'secret1');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('This username is already registered.'), findsOneWidget);
    fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), 'changed1');
    expect(
      tester.widget<TextFormField>(fields.at(2)).controller!.text,
      'changed1',
    );

    await tester.enterText(fields.at(1), 'secret2');
    await tester.enterText(fields.at(2), 'different');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'changed2');
    expect(
      tester.widget<TextFormField>(fields.at(1)).controller!.text,
      'changed2',
    );
  });
}

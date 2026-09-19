import 'package:flutter/foundation.dart';

import '../models/github_user.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _storageKey = 'favorite_users';

  final StorageService _storage;
  final List<GitHubUser> _favorites = [];
  String? _username;

  FavoritesProvider(this._storage);

  List<GitHubUser> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(GitHubUser user) => _favorites.contains(user);

  /// Loads the list saved for [username]. Without a user the list stays
  /// empty and nothing is persisted.
  Future<void> load([String? username]) async {
    _username = username;
    final savedFavorites =
        username == null ? null : await _storage.loadJson(_keyFor(username));
    if (_username != username) return;

    _favorites
      ..clear()
      ..addAll(_readUsers(savedFavorites));
    notifyListeners();
  }

  Future<void> toggle(GitHubUser user) async {
    if (isFavorite(user)) {
      _favorites.remove(user);
    } else {
      _favorites.add(user);
    }
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final username = _username;
    if (username == null) return;

    await _storage.saveJson(
      _keyFor(username),
      _favorites.map((favorite) => favorite.toJson()).toList(),
    );
  }

  String _keyFor(String username) => '$_storageKey:$username';

  List<GitHubUser> _readUsers(Object? value) {
    if (value is! List) return [];

    return value.whereType<Map>().map((item) {
      return GitHubUser.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}

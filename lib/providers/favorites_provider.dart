import 'package:flutter/foundation.dart';

import '../models/github_user.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _storageKey = 'favorite_users';

  final StorageService _storage;
  final List<GitHubUser> _favorites = [];

  FavoritesProvider(this._storage);

  List<GitHubUser> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(GitHubUser user) => _favorites.contains(user);

  Future<void> load() async {
    final savedFavorites = await _storage.loadJson(_storageKey);
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
    await _storage.saveJson(
      _storageKey,
      _favorites.map((favorite) => favorite.toJson()).toList(),
    );
  }

  List<GitHubUser> _readUsers(Object? value) {
    if (value is! List) return [];

    return value.whereType<Map>().map((item) {
      return GitHubUser.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}

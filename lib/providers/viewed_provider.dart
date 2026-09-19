import 'package:flutter/foundation.dart';

import '../models/github_user.dart';
import '../services/storage_service.dart';

class ViewedProvider extends ChangeNotifier {
  static const _storageKey = 'viewed_users';

  final StorageService _storage;
  final List<GitHubUser> _viewed = [];
  String? _username;

  ViewedProvider(this._storage);

  List<GitHubUser> get viewed => List.unmodifiable(_viewed);

  bool isViewed(GitHubUser user) => _viewed.contains(user);

  /// Loads the list saved for [username]. Without a user the list stays
  /// empty and nothing is persisted.
  Future<void> load([String? username]) async {
    _username = username;
    final savedViewed =
        username == null ? null : await _storage.loadJson(_keyFor(username));
    if (_username != username) return;

    _viewed
      ..clear()
      ..addAll(_readUsers(savedViewed));
    notifyListeners();
  }

  Future<void> markViewed(GitHubUser user) async {
    _viewed.remove(user);
    _viewed.insert(0, user);
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final username = _username;
    if (username == null) return;

    await _storage.saveJson(
      _keyFor(username),
      _viewed.map((viewedUser) => viewedUser.toJson()).toList(),
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

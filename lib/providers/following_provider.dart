import 'package:flutter/foundation.dart';

import '../models/github_user.dart';
import '../services/storage_service.dart';

class FollowingProvider extends ChangeNotifier {
  static const _storageKey = 'following_users';

  final StorageService _storage;
  final List<GitHubUser> _following = [];
  String? _username;

  FollowingProvider(this._storage);

  List<GitHubUser> get following => List.unmodifiable(_following);

  bool isFollowing(GitHubUser user) => _following.contains(user);

  /// Loads the list saved for [username]. Without a user the list stays
  /// empty and nothing is persisted.
  Future<void> load([String? username]) async {
    _username = username;
    final savedFollowing =
        username == null ? null : await _storage.loadJson(_keyFor(username));
    if (_username != username) return;

    _following
      ..clear()
      ..addAll(_readUsers(savedFollowing));
    notifyListeners();
  }

  Future<void> toggle(GitHubUser user) async {
    if (isFollowing(user)) {
      _following.remove(user);
    } else {
      _following.add(user);
    }
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final username = _username;
    if (username == null) return;

    await _storage.saveJson(
      _keyFor(username),
      _following.map((user) => user.toJson()).toList(),
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

import 'package:flutter/foundation.dart';

import '../models/github_user.dart';
import '../services/storage_service.dart';

class FollowingProvider extends ChangeNotifier {
  static const _storageKey = 'following_users';

  final StorageService _storage;
  final List<GitHubUser> _following = [];

  FollowingProvider(this._storage);

  List<GitHubUser> get following => List.unmodifiable(_following);

  bool isFollowing(GitHubUser user) => _following.contains(user);

  Future<void> load() async {
    final savedFollowing = await _storage.loadJson(_storageKey);
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
    await _storage.saveJson(
      _storageKey,
      _following.map((user) => user.toJson()).toList(),
    );
  }

  List<GitHubUser> _readUsers(Object? value) {
    if (value is! List) return [];

    return value.whereType<Map>().map((item) {
      return GitHubUser.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}

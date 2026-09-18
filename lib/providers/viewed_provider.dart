import 'package:flutter/foundation.dart';

import '../models/github_user.dart';
import '../services/storage_service.dart';

class ViewedProvider extends ChangeNotifier {
  static const _storageKey = 'viewed_users';

  final StorageService _storage;
  final List<GitHubUser> _viewed = [];

  ViewedProvider(this._storage);

  List<GitHubUser> get viewed => List.unmodifiable(_viewed);

  bool isViewed(GitHubUser user) => _viewed.contains(user);

  Future<void> load() async {
    final savedViewed = await _storage.loadJson(_storageKey);
    _viewed
      ..clear()
      ..addAll(_readUsers(savedViewed));
    notifyListeners();
  }

  Future<void> markViewed(GitHubUser user) async {
    _viewed.remove(user);
    _viewed.insert(0, user);
    notifyListeners();
    await _storage.saveJson(
      _storageKey,
      _viewed.map((viewedUser) => viewedUser.toJson()).toList(),
    );
  }

  List<GitHubUser> _readUsers(Object? value) {
    if (value is! List) return [];

    return value.whereType<Map>().map((item) {
      return GitHubUser.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}

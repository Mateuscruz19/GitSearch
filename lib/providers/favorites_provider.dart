import 'package:flutter/foundation.dart';

import '../models/github_user.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<GitHubUser> _favorites = [];

  List<GitHubUser> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(GitHubUser user) => _favorites.contains(user);

  void toggle(GitHubUser user) {
    if (isFavorite(user)) {
      _favorites.remove(user);
    } else {
      _favorites.add(user);
    }
    notifyListeners();
  }
}

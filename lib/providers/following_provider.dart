import 'package:flutter/foundation.dart';

import '../models/github_user.dart';

class FollowingProvider extends ChangeNotifier {
  final List<GitHubUser> _following = [];

  List<GitHubUser> get following => List.unmodifiable(_following);

  bool isFollowing(GitHubUser user) => _following.contains(user);

  void toggle(GitHubUser user) {
    if (isFollowing(user)) {
      _following.remove(user);
    } else {
      _following.add(user);
    }
    notifyListeners();
  }
}

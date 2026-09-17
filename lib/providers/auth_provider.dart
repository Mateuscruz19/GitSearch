import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;

  String? get username => _username;

  bool get isLoggedIn => _username != null;

  Future<void> login(String username) async {
    _username = username;
    notifyListeners();
  }

  Future<void> logout() async {
    _username = null;
    notifyListeners();
  }
}

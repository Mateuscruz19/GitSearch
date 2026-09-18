import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_session';

  final StorageService _storage;
  String? _username;

  AuthProvider(this._storage);

  String? get username => _username;

  bool get isLoggedIn => _username != null;

  Future<void> restoreSession() async {
    final savedUsername = await _storage.loadJson(_sessionKey);
    final users = await _loadUsers();

    if (savedUsername is String && users.containsKey(savedUsername)) {
      _username = savedUsername;
    } else {
      await _storage.remove(_sessionKey);
    }
  }

  Future<String?> register(String username, String password) async {
    final normalizedUsername = _normalizeUsername(username);
    final validationError = _validate(normalizedUsername, password);
    if (validationError != null) return validationError;

    final users = await _loadUsers();
    if (users.containsKey(normalizedUsername)) {
      return 'This username is already registered.';
    }

    users[normalizedUsername] = _hashPassword(normalizedUsername, password);
    await _storage.saveJson(_usersKey, users);
    await _startSession(normalizedUsername);
    return null;
  }

  Future<String?> login(String username, String password) async {
    final normalizedUsername = _normalizeUsername(username);
    final validationError = _validate(normalizedUsername, password);
    if (validationError != null) return validationError;

    final users = await _loadUsers();
    final savedPassword = users[normalizedUsername];
    if (savedPassword != _hashPassword(normalizedUsername, password)) {
      return 'Invalid username or password.';
    }

    await _startSession(normalizedUsername);
    return null;
  }

  Future<void> _startSession(String username) async {
    await _storage.saveJson(_sessionKey, username);
    _username = username;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.remove(_sessionKey);
    _username = null;
    notifyListeners();
  }

  Future<Map<String, String>> _loadUsers() async {
    final savedUsers = await _storage.loadJson(_usersKey);
    if (savedUsers is! Map) return {};

    return {
      for (final entry in savedUsers.entries)
        if (entry.value is String) entry.key.toString(): entry.value as String,
    };
  }

  String _normalizeUsername(String username) => username.trim().toLowerCase();

  String? _validate(String username, String password) {
    if (username.length < 3) {
      return 'Username must have at least 3 characters.';
    }
    if (password.length < 6) {
      return 'Password must have at least 6 characters.';
    }
    return null;
  }

  String _hashPassword(String username, String password) {
    return sha256.convert(utf8.encode('$username:$password')).toString();
  }
}

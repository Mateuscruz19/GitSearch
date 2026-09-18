import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<void> saveJson(String key, Object value);

  Future<Object?> loadJson(String key);

  Future<void> remove(String key);
}

class SharedPreferencesStorageService implements StorageService {
  final SharedPreferencesAsync _preferences;

  SharedPreferencesStorageService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  @override
  Future<void> saveJson(String key, Object value) async {
    await _preferences.setString(key, jsonEncode(value));
  }

  @override
  Future<Object?> loadJson(String key) async {
    final value = await _preferences.getString(key);
    if (value == null) return null;

    try {
      return jsonDecode(value);
    } on FormatException {
      await remove(key);
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}

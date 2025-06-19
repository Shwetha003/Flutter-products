import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // One instance per app
  static final _storage = FlutterSecureStorage();

  // Keys
  static const _loggedInKey = 'logged_in';

  // Write a boolean as string
  static Future<void> setLoggedIn(bool value) =>
      _storage.write(key: _loggedInKey, value: value ? 'true' : 'false');

  // Read, defaulting to false
  static Future<bool> getLoggedIn() async {
    final v = await _storage.read(key: _loggedInKey);
    return v == 'true';
  }

  // Optional: clear all
  static Future<void> clearAll() => _storage.deleteAll();
}

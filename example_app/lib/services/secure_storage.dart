import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecureStorage {
  // One instance per app
  static final _storage = FlutterSecureStorage();
  static const _credentialsKey = "credentials";

  // Keys
  //static const _loggedInKey = 'logged_in';

  //hasf func for passwords
  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Add new user credentials
  static Future<void> addCredential({
    required String email,
    required String password,
  }) async {
    final credentials = await getCredentialsList();

    if (credentials.any((entry) => entry['email'] == email)) {
      throw Exception('Email already registered');
    }

    credentials.add({'email': email, 'password': _hashPassword(password)});

    final jsonString = jsonEncode(credentials);
    await _storage.write(key: _credentialsKey, value: jsonString);
  }

  // Get list of all credentials
  static Future<List<Map<String, String>>> getCredentialsList() async {
    final jsonString = await _storage.read(key: _credentialsKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  // Check login credentials
  static Future<bool> checkLogin({
    required String email,
    required String password,
  }) async {
    final credentials = await getCredentialsList();
    final hashedPassword = _hashPassword(password);

    final user = credentials.firstWhere(
      (entry) => entry['email'] == email,
      orElse: () => {},
    );

    if (user.isEmpty) {
      return false;
    }

    return user['password'] == hashedPassword;
  }

  // Optional: clear all
  static Future<void> clearAll() => _storage.deleteAll();
}

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthModel extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _loggedIn = false;
  bool _initialized = false;

  bool get loggedIn => _loggedIn;
  bool get initialized => _initialized;

  AuthModel() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final value = await _storage.read(key: 'loggedIn');
    _loggedIn = value == 'true';
    _initialized = true;
    notifyListeners();
  }

  Future<bool> loginWithEmail(String email, String password) async {
    // read stored credentials
    final storedEmail = await _storage.read(key: 'registeredEmail');
    final storedPass = await _storage.read(key: 'registeredPassword');
    if (storedEmail == email && storedPass == password) {
      _loggedIn = true;
      await _storage.write(key: 'loggedIn', value: 'true');
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> registerWithEmail(String email, String password) async {
    // store credentials
    await _storage.write(key: 'registeredEmail', value: email);
    await _storage.write(key: 'registeredPassword', value: password);
  }
  /*Future<bool> loginWithEmail(String email, String password) async {
    // Dummy check: only one registered user
    const registeredEmail = 'user@example.com';
    const registeredPassword = 'password123';

    if (email == registeredEmail && password == registeredPassword) {
      _loggedIn = true;
      await _storage.write(key: 'loggedIn', value: 'true');
      notifyListeners();
      return true;
    }
    return false;
  } */

  Future<void> logout() async {
    _loggedIn = false;
    await _storage.delete(key: 'loggedIn');
    notifyListeners();
  }
}

  /*
  void login() {
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }
  */


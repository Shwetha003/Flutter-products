import 'package:example_app/services/secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthModel extends ChangeNotifier {
  //final FlutterSecureStorage _storage = const FlutterSecureStorage();  -->we are no longer directly talking to the storage, now we call from the secure storage file
  bool _loggedIn = false;
  bool _initialized = false;
  String? _currentUserEmail;

  bool get loggedIn => _loggedIn;
  bool get initialized => _initialized;
  String? get currentUserEmail => _currentUserEmail;

  AuthModel() {
    _initialize();
  }

  //initialize when app starts
  Future<void> _initialize() async {
    _loggedIn = false;
    _initialized = true;
    notifyListeners();
  }

  //register user
  Future<bool> registerWithEmail(String email, String password) async {
    try {
      await SecureStorage.addCredential(email: email, password: password);
      return true;
    } catch (e) {
      return false; //when email already exists
    }
  }

  //login user
  Future<bool> loginWithEmail(String email, String password) async {
    final success = await SecureStorage.checkLogin(
      email: email,
      password: password,
    );
    if (success) {
      _loggedIn = true;
      _currentUserEmail = email;
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    _loggedIn = false;
    _currentUserEmail = null;
    notifyListeners();
  }
}

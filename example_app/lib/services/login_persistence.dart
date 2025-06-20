import 'package:shared_preferences/shared_preferences.dart';

class LoginPersistence {
  static const _loggedInKey = 'logged_in';

  // Store loggedIn state
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  // Retrieve loggedIn state
  static Future<bool> getLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  // Clear loggedIn state (used on logout)
  static Future<void> clearLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
  }
}

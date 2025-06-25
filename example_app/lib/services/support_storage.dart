// lib/services/support_storage.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class SupportStorage {
  static const _historyKey = 'support_history';

  /// Load the saved chat history. Returns empty list if none.
  static Future<List<Message>> loadSupportHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];
    try {
      return Message.decodeList(jsonString);
    } catch (_) {
      // If parse fails, wipe and return empty
      await prefs.remove(_historyKey);
      return [];
    }
  }

  /// Save the full chat history.
  static Future<void> saveSupportHistory(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = Message.encodeList(messages);
    await prefs.setString(_historyKey, jsonString);
  }
}

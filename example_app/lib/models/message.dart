// lib/models/message.dart

import 'dart:convert';

/// Who sent the message: the user, or our echo‐bot.
enum Sender { user, echo }

/// A single chat message entry.
class Message {
  final String text;
  final Sender sender;
  final DateTime timestamp;

  Message({required this.text, required this.sender, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  /// Convert to a JSON‐compatible Map.
  Map<String, dynamic> toJson() => {
    'text': text,
    'sender': sender == Sender.user ? 'user' : 'echo',
    'timestamp': timestamp.toIso8601String(),
  };

  /// Create from JSON Map.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] as String,
      sender: (json['sender'] as String) == 'user' ? Sender.user : Sender.echo,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// For convenience: encode a List<Message> to a JSON string.
  static String encodeList(List<Message> messages) =>
      jsonEncode(messages.map((m) => m.toJson()).toList());

  /// Decode a JSON string into List<Message>.
  static List<Message> decodeList(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list
        .map((item) => Message.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

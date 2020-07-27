import 'user.dart';

class ChatMessage {
  final User from;
  final User to;
  final String text;
  final bool isRead;
  DateTime timestamp;

  ChatMessage({
    this.from,
    this.to,
    this.text,
    DateTime timestamp,
    this.isRead = false,
  }) {
    this.timestamp = timestamp ?? DateTime.now();
  }
}

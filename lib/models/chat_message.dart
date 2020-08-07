import 'user.dart';

class ChatMessage {
  final User from;
  final User to;
  final String text;
  final bool isRead;
  DateTime timestamp;

  // TODO: need better image detection:
  bool get isImage =>
      text.startsWith("http://") && text.contains("/httpfileupload/");

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

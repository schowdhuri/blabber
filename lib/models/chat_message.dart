import 'user.dart';

class ChatMessage {
  final User from;
  final User to;
  final String text;
  DateTime timestamp;

  ChatMessage({this.from, this.to, this.text, DateTime timestamp}) {
    this.timestamp = timestamp ?? DateTime.now();
  }
}

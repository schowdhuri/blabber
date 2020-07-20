import 'user.dart';

class Message {
  final User from;
  final User to;
  final String text;
  DateTime timestamp;

  Message({this.from, this.to, this.text, DateTime timestamp}) {
    this.timestamp = timestamp ?? DateTime.now();
  }
}

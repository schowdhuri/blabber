import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'client.dart';

class MessagesListener implements xmpp.MessagesListener {
  final MessageCallbackType onData;

  MessagesListener(this.onData);

  @override
  onNewMessage(xmpp.MessageStanza message) {
    if (message.body != null) {
      print(
          "New Message from ${message.fromJid.userAtDomain}\nmessage: ${message.body}");
      onData(
        message.body,
        fromUsername: message.fromJid.userAtDomain,
        toUsername: message.toJid.userAtDomain,
        isReceived: true,
      );
    }
  }
}

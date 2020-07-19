import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

class MessagesListener implements xmpp.MessagesListener {
  final Function onData;

  MessagesListener(this.onData);

  @override
  onNewMessage(xmpp.MessageStanza message) {
    if (message.body != null) {
      print(
          "New Message from ${message.fromJid.userAtDomain}\nmessage: ${message.body}");
      onData(message.body);
    }
  }
}

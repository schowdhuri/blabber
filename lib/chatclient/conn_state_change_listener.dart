import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'dart:io';
// import 'dart:async';

class ConnectionStateChangedListener
    implements xmpp.ConnectionStateChangedListener {
  xmpp.Connection _connection;
  xmpp.MessagesListener _messagesListener;

  // StreamSubscription<String> subscription;

  ConnectionStateChangedListener(
      xmpp.Connection connection, xmpp.MessagesListener messagesListener) {
    _connection = connection;
    _messagesListener = messagesListener;
    _connection.connectionStateStream.listen(onConnectionStateChanged);
  }

  @override
  void onConnectionStateChanged(xmpp.XmppConnectionState state) {
    if (state == xmpp.XmppConnectionState.Ready) {
      print("Connected");
      xmpp.VCardManager vCardManager = xmpp.VCardManager(_connection);
      vCardManager.getSelfVCard().then((vCard) {
        if (vCard != null) {
          print("Your info" + vCard.buildXmlString());
        }
      });
      xmpp.MessageHandler messageHandler =
          xmpp.MessageHandler.getInstance(_connection);
      xmpp.RosterManager rosterManager =
          xmpp.RosterManager.getInstance(_connection);
      messageHandler.messagesStream.listen(_messagesListener.onNewMessage);
      sleep(const Duration(seconds: 1));
      //print("Enter receiver jid: ");
      //var receiver = stdin.readLineSync(encoding: utf8);
      var receiver = "nemanja2@test";
      xmpp.Jid receiverJid = xmpp.Jid.fromFullJid(receiver);
      rosterManager.addRosterItem(xmpp.Buddy(receiverJid)).then((result) {
        if (result.description != null) {
          print("add roster" + result.description);
        }
      });
      sleep(const Duration(seconds: 1));
      xmpp.PresenceManager presenceManager =
          xmpp.PresenceManager.getInstance(_connection);
      presenceManager.presenceStream.listen(onPresence);
    }
  }

  void onPresence(xmpp.PresenceData event) {
    print("presence Event from " +
        event.jid.fullJid +
        " PRESENCE: " +
        event.showElement.toString());
  }
}

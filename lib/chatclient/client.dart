import 'dart:convert';
import "package:console/console.dart";
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:chat/chatclient/message_listener.dart';

class ChatClient {
  final String userAtDomain;
  final String password;
  final int port;
  final String host;
  MessagesListener _messagesListener;
  xmpp.MessageHandler _messageHandler;
  xmpp.Connection _connection;

  ChatClient({
    this.userAtDomain,
    this.password,
    this.port,
    this.host,
  });

  Future<void> connect() async {
    xmpp.Jid jid = xmpp.Jid.fromFullJid(userAtDomain);
    xmpp.XmppAccountSettings account = xmpp.XmppAccountSettings(
      userAtDomain,
      jid.local,
      jid.domain,
      password,
      port,
      host: host,
    );
    _connection = xmpp.Connection(account);
    _connection.connect();

    _messageHandler = xmpp.MessageHandler.getInstance(_connection);
    xmpp.PresenceManager presenceManager =
        xmpp.PresenceManager.getInstance(_connection);
    presenceManager.subscriptionStream.listen((streamEvent) {
      if (streamEvent.type == xmpp.SubscriptionEventType.REQUEST) {
        print("Accepting presence request");
        presenceManager.acceptSubscription(streamEvent.jid);
      }
    });
    // _connectionStateChangedListener = ConnectionStateChangedListener(
    //   _connection,
    //   _messagesListener,
    // );
  }

  void addMessageListener(Function onMessageReceived) {
    _messagesListener = MessagesListener(onMessageReceived);
    _messageHandler.messagesStream.listen(_messagesListener.onNewMessage);
  }

  void sendMessage(String receiver, String msg) {
    xmpp.Jid receiverJid = xmpp.Jid.fromFullJid(receiver);
    _messageHandler.sendMessage(receiverJid, msg);
  }

  Stream<String> getConsoleStream() {
    return Console.adapter.byteStream().map((bytes) {
      var str = ascii.decode(bytes);
      str = str.substring(0, str.length - 1);
      return str;
    });
  }
}

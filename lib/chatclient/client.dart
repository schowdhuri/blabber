import 'dart:convert';
import "package:console/console.dart";
import 'package:flutter/foundation.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:chat/chatclient/conn_state_change_listener.dart';
import 'package:chat/chatclient/message_listener.dart';

class ChatClient {
  final String userAtDomain;
  final String password;
  final int port;
  final String host;
  final Function onMessageReceived;
  xmpp.Connection _connection;

  ChatClient({
    this.userAtDomain,
    this.password,
    this.port,
    this.host,
    this.onMessageReceived,
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

    // xmpp.MessagesListener messagesListener =
    //     MessagesListener(onMessageReceived);
    // ConnectionStateChangedListener(_connection, messagesListener);
    // xmpp.PresenceManager presenceManager =
    //     xmpp.PresenceManager.getInstance(_connection);
    // presenceManager.subscriptionStream.listen((streamEvent) {
    //   if (streamEvent.type == xmpp.SubscriptionEventType.REQUEST) {
    //     print("Accepting presence request");
    //     presenceManager.acceptSubscription(streamEvent.jid);
    //   }
    // });
  }

  void sendMessage(String receiver, String msg) {
    xmpp.Jid receiverJid = xmpp.Jid.fromFullJid(receiver);
    xmpp.MessageHandler messageHandler =
        xmpp.MessageHandler.getInstance(_connection);
    messageHandler.sendMessage(receiverJid, msg);
  }

  Stream<String> getConsoleStream() {
    return Console.adapter.byteStream().map((bytes) {
      var str = ascii.decode(bytes);
      str = str.substring(0, str.length - 1);
      return str;
    });
  }
}

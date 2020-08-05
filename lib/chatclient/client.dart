import 'dart:convert';
import "package:console/console.dart";
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:xmpp_stone/src/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_stone/src/elements/stanzas/IqStanza.dart';

import 'message_listener.dart';

typedef void MessageCallbackType(String message,
    {String fromUsername, String toUsername, bool isReceived});

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

  String get domain => userAtDomain?.split("@")?.last;

  Future<bool> connect() async {
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

    await _connection.openSocket();
    if (!_connection.isOpened() ||
        _connection.state == xmpp.XmppConnectionState.Idle) {
      return false;
    }

    _messageHandler = xmpp.MessageHandler.getInstance(_connection);
    xmpp.PresenceManager presenceManager =
        xmpp.PresenceManager.getInstance(_connection);
    presenceManager.subscriptionStream.listen((streamEvent) {
      if (streamEvent.type == xmpp.SubscriptionEventType.REQUEST) {
        print("Accepting presence request");
        presenceManager.acceptSubscription(streamEvent.jid);
      }
    });
    return true;
  }

  void addMessageListener(MessageCallbackType onMessageReceived) {
    _messagesListener = MessagesListener(onMessageReceived);
    _messageHandler.messagesStream.listen(_messagesListener.onNewMessage);
  }

  void _processVCard(IqStanza stanza, Function onVCardReceived) {
    var vCardChild = stanza.getChild("vCard");
    if (vCardChild == null) {
      return;
    }
    try {
      if (vCardChild.getChild("PHOTO")?.getChild("BINVAL") != null) {
        String b64Image =
            vCardChild.getChild("PHOTO").getChild("BINVAL").textValue;
        vCardChild.getChild("PHOTO").getChild("BINVAL").textValue =
            b64Image = b64Image.replaceAll("\n", "");
      }
      xmpp.VCard vCard = xmpp.VCard(vCardChild);
      onVCardReceived(
        vCard,
        key: stanza.id,
      );
    } catch (ex) {
      onVCardReceived(
        null,
        error: xmpp.InvalidVCard(vCardChild),
      );
    }
  }

  void _processFileUpload(IqStanza stanza, Function onFileUploadResponse) {
    // https://xmpp.org/extensions/xep-0363.html

    String key = stanza.id;
    var query = stanza.getChild("query");
    if (query != null) {
      var x = query.getChild("x");
      if (x != null) {
        // max-file-size
        try {
          var field = x.children.firstWhere(
              (f) => f.getAttribute("var").value == "max-file-size");
          if (field == null) {
            return;
          }
          var value = field.getChild("value");
          if (value == null) {
            return;
          }
          onFileUploadResponse(
            key: key,
            maxFileSize: int.parse(value.textValue),
          );
          return;
        } catch (ex0) {
          print(ex0);
        }
      }
    }
    // upload slot
    var slot = stanza.getChild("slot");
    if (slot == null) {
      return;
    }
    String getUrl = slot
        .getChild("get")
        ?.getAttribute("url")
        ?.value
        ?.replaceAll(domain, host)
        ?.replaceAll("7443", "7070");
    String putUrl = slot
        .getChild("put")
        ?.getAttribute("url")
        ?.value
        ?.replaceAll(domain, host)
        ?.replaceAll("7443", "7070");
    if (getUrl == null || putUrl == null) {
      return;
    }
    onFileUploadResponse(
      key: key,
      getUrl: getUrl,
      putUrl: putUrl,
    );
  }

  void addIQListener(Function onVCardReceived, Function onFileUploadResponse) {
    _connection.inStanzasStream.listen((AbstractStanza stanza) {
      if (stanza is IqStanza) {
        if (stanza.type == IqStanzaType.RESULT) {
          _processVCard(stanza, onVCardReceived);
          _processFileUpload(stanza, onFileUploadResponse);
        } else if (stanza.type == IqStanzaType.ERROR) {
          // TODO: process error?
        }
      }
    });
  }

  void sendMessage(String receiver, String msg) {
    xmpp.Jid receiverJid = xmpp.Jid.fromFullJid(receiver);
    _messageHandler.sendMessage(receiverJid, msg);
  }

  xmpp.XmppAccountSettings getAccountDetails() {
    return _connection.account;
  }

  Stream<String> getConsoleStream() {
    return Console.adapter.byteStream().map((bytes) {
      var str = ascii.decode(bytes);
      str = str.substring(0, str.length - 1);
      return str;
    });
  }

  void sendRawXml(String rawXml) {
    _connection.write(rawXml);
  }
}

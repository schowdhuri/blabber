import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

enum MessageType {
  ConnectRequest,
  ConnectSuccess,
  ConnectFail,
  MessageReceived,
  SendRequest,
  SendSuccess,
  SendFail,
  ShareSendPort,
  SendRawXml,
  SendRawXmlSuccess,
  SendRawXmlFailure,
  GetVCard,
  GetVCardSuccess,
  GetVCardFailure,
  SaveVCard,
  SaveVCardSuccess,
  SaveVCardFailure,
  VCardReceived,
  VCardError,
}

class ConnectPayload {
  final String host;
  final int port;
  final String username;
  final String password;
  final String key;

  ConnectPayload({
    this.host,
    this.port,
    this.username,
    this.password,
    this.key,
  });
}

class ConnectResponsePayload {
  final String key;
  final ResponseStatus status;

  ConnectResponsePayload({
    this.key,
    this.status,
  });
}

class ChatMessagePayload {
  final String fromUsername;
  final String toUsername;
  final String message;
  ChatMessagePayload({this.fromUsername, this.toUsername, this.message});
}

class SaveVCardPayload {
  final String xml;
  final String key;

  SaveVCardPayload({
    this.xml,
    this.key,
  });
}

class VCardResponsePayload {
  final xmpp.VCard vCard;
  final String key;

  VCardResponsePayload({this.vCard, this.key});
}

class IsolateMessage {
  final MessageType type;
  final dynamic payload;

  IsolateMessage({this.type, this.payload});
}

class ClientResponse {
  final ResponseStatus status;
  final dynamic payload;
  ClientResponse({this.status, this.payload});
}

enum ResponseStatus { Pending, Success, Fail }

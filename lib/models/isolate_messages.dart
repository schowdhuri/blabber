enum MessageType {
  ConnectRequest,
  ConnectSuccess,
  ConnectFail,
  MessageReceived,
  SendRequest,
  SendSuccess,
  SendFail,
  ShareSendPort,
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
  final String username;
  final String message;
  ChatMessagePayload({this.username, this.message});
}

class IsolateMessage {
  final MessageType type;
  final dynamic payload;

  IsolateMessage({this.type, this.payload});
}

enum ResponseStatus { Pending, Success, Fail }

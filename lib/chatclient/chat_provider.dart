import 'dart:isolate';
import 'package:uuid/uuid.dart';

import '../models/connection_settings.dart';
import '../models/user.dart';
import '../models/isolate_messages.dart';
import 'client.dart';

class ChatProvider {
  Isolate _isolate;
  ReceivePort _receivePort;
  SendPort _sendPort;
  bool _isStarted = false;
  Function _onReceiveChat;
  Uuid _uuid = Uuid();
  Map<String, ResponseStatus> _responseMap = {};

  ChatProvider._pvtConstructor();
  static final ChatProvider _instance = ChatProvider._pvtConstructor();
  factory ChatProvider() => _instance;

  Future<void> start() async {
    if (_isStarted) {
      return;
    }
    _isStarted = true;
    _receivePort = ReceivePort();
    _receivePort.listen(onMessage);
    _isolate = await Isolate.spawn(_run, _receivePort.sendPort);
  }

  Future<bool> connect(ConnectionSettings connectionSettings, User user) async {
    print("starting connect...");
    String key = _uuid.v1();
    _responseMap[key] = ResponseStatus.Pending;
    _sendPort.send(
      IsolateMessage(
        type: MessageType.ConnectRequest,
        payload: ConnectPayload(
          host: connectionSettings.host,
          port: connectionSettings.port,
          username: user.username,
          password: user.password,
          key: key,
        ),
      ),
    );
    ResponseStatus resp = await _waitForResponse(key);
    return resp == ResponseStatus.Success;
  }

  void addMessageListener(Function callback) {
    _onReceiveChat = callback;
  }

  void sendMessage(String username, String message) {
    _sendPort.send(
      IsolateMessage(
        type: MessageType.SendRequest,
        payload: ChatMessagePayload(
          username: username,
          message: message,
        ),
      ),
    );
  }

  Future<ResponseStatus> _waitForResponse(String key) async {
    if (_responseMap[key] == null) {
      throw AssertionError("Response container not found");
    }
    if (_responseMap[key] != ResponseStatus.Pending) {
      return _responseMap[key];
    }
    print("Response: ${key.toString()} = ${_responseMap[key]}");
    await Future.delayed(Duration(milliseconds: 1000));
    return _waitForResponse(key);
  }

  onMessage(dynamic msg) {
    IsolateMessage message = msg as IsolateMessage;
    print("Isolate says: ${message.type}");

    switch (message.type) {
      case MessageType.ShareSendPort:
        _sendPort = message.payload as SendPort;
        print("_sendport ready");
        break;

      case MessageType.ConnectFail:
      case MessageType.ConnectSuccess:
        ConnectResponsePayload resp = message.payload;
        _responseMap[resp.key] = resp.status;
        print(
            "Response updated to: ${resp.key.toString()} = ${_responseMap[resp.key]}");
        break;

      case MessageType.MessageReceived:
        if (_onReceiveChat != null) {
          _onReceiveChat(message.payload as String);
        }
        break;
      default:
    }
  }
}

void _run(SendPort sendPort) {
  ChatClient chatClient;
  ReceivePort _receivePort = ReceivePort();

  sendPort.send(
    IsolateMessage(
      type: MessageType.ShareSendPort,
      payload: _receivePort.sendPort,
    ),
  );

  Future<void> connect(ConnectPayload data) async {
    print(
        "connect request received ${data.username}@${data.host}:${data.port}");
    chatClient = ChatClient(
      host: data.host,
      port: data.port,
      userAtDomain: data.username,
      password: data.password,
    );

    bool isOpened = await chatClient.connect();
    if (!isOpened) {
      return sendPort.send(
        IsolateMessage(
          type: MessageType.ConnectFail,
          payload: ConnectResponsePayload(
            key: data.key,
            status: ResponseStatus.Fail,
          ),
        ),
      );
    }
    sendPort.send(
      IsolateMessage(
        type: MessageType.ConnectSuccess,
        payload: ConnectResponsePayload(
          key: data.key,
          status: ResponseStatus.Success,
        ),
      ),
    );
    chatClient.addMessageListener((String message) {
      print("Received message at Isolate: $message");
      sendPort.send(
        IsolateMessage(
          type: MessageType.MessageReceived,
          payload: message,
        ),
      );
    });
  }

  void sendMessage(ChatMessagePayload data) {
    chatClient.sendMessage(data.username, data.message);
    sendPort.send(
      IsolateMessage(
        type: MessageType.SendSuccess,
      ),
    );
  }

  _receivePort.listen((msg) {
    IsolateMessage message = msg as IsolateMessage;
    if (message.type == MessageType.ConnectRequest) {
      connect(message.payload as ConnectPayload);
    } else if (message.type == MessageType.SendRequest) {
      sendMessage(message.payload as ChatMessagePayload);
    }
  });
}

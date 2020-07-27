import 'dart:isolate';
import 'package:chat/models/buddy.dart';
import 'package:chat/models/chat_message.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_history.dart';
import '../models/connection_settings.dart';
import '../models/user.dart';
import '../models/isolate_messages.dart';
import 'client.dart';

class ChatProvider {
  ReceivePort _receivePort;
  SendPort _sendPort;
  bool _isStarted = false;
  Map<String, MessageCallbackType> _messageCallbacks = {};
  Uuid _uuid = Uuid();
  Map<String, ResponseStatus> _responseMap = {};
  ChatHistoryProvider _historyProvider = ChatHistoryProvider();
  BuddyProvider _buddyProvider = BuddyProvider();

  ChatProvider._pvtConstructor();
  static final ChatProvider _instance = ChatProvider._pvtConstructor();
  factory ChatProvider() => _instance;

  Future<void> init() async {
    if (_isStarted) {
      return;
    }
    _isStarted = true;
    _receivePort = ReceivePort();
    _receivePort.listen(onIsolateMessage);
    await Isolate.spawn(_run, _receivePort.sendPort);
  }

  Future<bool> connect(ConnectionSettings connectionSettings, User user) async {
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

  Function addMessageListener(MessageCallbackType callback) {
    String uuid = _uuid.v1();
    _messageCallbacks[uuid] = callback;
    return () {
      _messageCallbacks.remove(uuid);
    };
  }

  Future<void> sendMessage(String username, String message) async {
    _sendPort.send(
      IsolateMessage(
        type: MessageType.SendRequest,
        payload: ChatMessagePayload(
          toUsername: username,
          message: message,
        ),
      ),
    );
    // add to history
    Buddy buddy = await _buddyProvider.get(username);
    await _historyProvider.add(
      buddy,
      ChatMessage(
        to: buddy,
        text: message,
        isRead: true,
      ),
    );
    // notify listeners
    _messageCallbacks.forEach((_, MessageCallbackType cb) {
      cb(
        message,
        fromUsername: username,
        isReceived: false,
      );
    });
  }

  Future<void> onReceiveMessage(ChatMessagePayload chatMessagePayload) async {
    // add to history
    Buddy buddy = await _buddyProvider.get(chatMessagePayload.fromUsername);
    await _historyProvider.add(
      buddy,
      ChatMessage(
        from: buddy,
        text: chatMessagePayload.message,
        isRead: false,
      ),
    );
    // notify listeners
    _messageCallbacks.forEach((_, MessageCallbackType cb) {
      cb(
        chatMessagePayload.message,
        fromUsername: chatMessagePayload.fromUsername,
        toUsername: chatMessagePayload.toUsername,
        isReceived: true,
      );
    });
  }

  Future<ResponseStatus> _waitForResponse(String key) async {
    if (_responseMap[key] == null) {
      throw AssertionError("Response container not found");
    }
    if (_responseMap[key] != ResponseStatus.Pending) {
      return _responseMap[key];
    }
    await Future.delayed(Duration(milliseconds: 1000));
    return _waitForResponse(key);
  }

  onIsolateMessage(dynamic msg) {
    IsolateMessage message = msg as IsolateMessage;

    switch (message.type) {
      case MessageType.ShareSendPort:
        _sendPort = message.payload as SendPort;
        break;

      case MessageType.ConnectFail:
      case MessageType.ConnectSuccess:
        ConnectResponsePayload resp = message.payload;
        _responseMap[resp.key] = resp.status;
        break;

      case MessageType.MessageReceived:
        onReceiveMessage(msg.payload as ChatMessagePayload);
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
    chatClient.addMessageListener((String message,
        {String fromUsername, String toUsername, bool isReceived = true}) {
      sendPort.send(
        IsolateMessage(
          type: MessageType.MessageReceived,
          payload: ChatMessagePayload(
            fromUsername: fromUsername,
            toUsername: toUsername,
            message: message,
          ),
        ),
      );
    });
  }

  void sendMessage(ChatMessagePayload data) {
    chatClient.sendMessage(data.toUsername, data.message);
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

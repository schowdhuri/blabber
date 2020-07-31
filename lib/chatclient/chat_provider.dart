import 'dart:isolate';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

import '../models/buddy.dart';
import '../models/chat_message.dart';
import '../models/chat_history.dart';
import '../models/connection_settings.dart';
import '../models/user.dart';
import '../models/isolate_messages.dart';
import 'client.dart';

class ChatProvider {
  ReceivePort _receivePort;
  SendPort _sendPort;
  bool _isStarted = false;
  User _user;
  Map<String, MessageCallbackType> _messageCallbacks = {};
  Uuid _uuid = Uuid();
  Map<String, ClientResponse> _responseMap = {};
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
    _responseMap[key] = ClientResponse(status: ResponseStatus.Pending);
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
    ClientResponse resp = await _waitForResponse(key);
    _user = user;
    return resp.status == ResponseStatus.Success;
  }

  String getUsername() {
    return _user != null ? _user.username : null;
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

  Future<User> getMyProfile() async {
    String key = _uuid.v1();
    _responseMap[key] = ClientResponse(status: ResponseStatus.Pending);
    String xml = """
      <iq from='${_user.username}'
          id='$key'
          type='get'>
        <vCard xmlns='vcard-temp'/>
      </iq>""";
    sendRawXml(xml);
    ClientResponse resp = await _waitForResponse(key);
    xmpp.VCard vCard = resp.payload as xmpp.VCard;
    return User(
      username: vCard.jabberId ?? _user.username,
      name: vCard.fullName,
      imageData: vCard.imageData,
    );
  }

  Future<void> updateProfile(User user,
      {Uint8List imageData, String name}) async {
    String key = _uuid.v1();
    _responseMap[key] = ClientResponse(status: ResponseStatus.Pending);

    _sendPort.send(
      IsolateMessage(
        type: MessageType.SaveVCard,
        payload: SaveVCardPayload(
          id: key,
          fullName: name != null && name.isNotEmpty ? name : user.name,
          imageData: imageData ?? user.imageData,
          jabberId: user.username,
        ),
      ),
    );
    await _waitForResponse(key);
  }

  void sendRawXml(String rawXml) {
    _sendPort.send(
      IsolateMessage(
        type: MessageType.SendRawXml,
        payload: rawXml,
      ),
    );
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

  Future<ClientResponse> _waitForResponse(String key) async {
    if (_responseMap[key] == null) {
      throw AssertionError("Response container not found");
    }
    if (_responseMap[key].status != ResponseStatus.Pending) {
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
        {
          ConnectResponsePayload resp = message.payload;
          _responseMap[resp.key] = ClientResponse(status: resp.status);
          break;
        }

      case MessageType.MessageReceived:
        onReceiveMessage(msg.payload as ChatMessagePayload);
        break;

      case MessageType.VCardReceived:
        {
          VCardResponsePayload resp = msg.payload;
          _responseMap[resp.key] = ClientResponse(
            status: ResponseStatus.Success,
            payload: resp.vCard,
          );
          break;
        }

      default:
    }
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
    chatClient
        .addVCardListener((xmpp.VCard vCard, {String key, dynamic error}) {
      if (error == null) {
        sendPort.send(
          IsolateMessage(
            type: MessageType.VCardReceived,
            payload: VCardResponsePayload(
              vCard: vCard,
              key: key,
            ),
          ),
        );
      } else {
        sendPort.send(
          IsolateMessage(
            type: MessageType.VCardError,
            payload: error,
          ),
        );
      }
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
    switch (message.type) {
      case MessageType.ConnectRequest:
        connect(message.payload as ConnectPayload);
        break;

      case MessageType.SendRequest:
        sendMessage(message.payload as ChatMessagePayload);
        break;

      case MessageType.SendRawXml:
        chatClient.sendRawXml(message.payload as String);
        break;

      case MessageType.SaveVCard:
        {
          SaveVCardPayload payload = msg.payload;
          String xml = "<iq from='${payload.jabberId}'"
              "id='${payload.id}' type='set'>"
              "<vCard xmlns='vcard-temp'>"
              "<FN>${payload.fullName}</FN>"
              "<PHOTO>"
              "<TYPE>image/jpeg</TYPE>"
              "<BINVAL>${payload.b64ImageData}</BINVAL>"
              "</PHOTO>"
              "<JABBERID>${payload.jabberId}</JABBERID>"
              "</vCard>"
              "</iq>";
          chatClient.sendRawXml(xml);
          break;
        }
      default:
    }
  });
}

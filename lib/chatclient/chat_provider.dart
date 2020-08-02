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
  Function _onNewChat;
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

  Function addNewChatListener(Function callback) {
    _onNewChat = callback;
    return () {
      _onNewChat = null;
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
    _sendPort.send(
      IsolateMessage(
        type: MessageType.GetVCard,
        payload: GetVCardPayload(
          id: key,
          fromUsername: _user.username,
          toUsername: _user.username,
        ),
      ),
    );
    ClientResponse resp = await _waitForResponse(key);
    xmpp.VCard vCard = resp.payload as xmpp.VCard;
    return User(
      username: vCard.jabberId ?? _user.username,
      name: vCard.fullName != "null" ? vCard.fullName : null,
      imageData: vCard.imageData,
    );
  }

  Future<Buddy> getBuddyProfile(Buddy buddy) =>
      getProfileByUsername(buddy.username);

  Future<Buddy> getProfileByUsername(String username) async {
    String key = _uuid.v1();
    _responseMap[key] = ClientResponse(status: ResponseStatus.Pending);
    _sendPort.send(
      IsolateMessage(
        type: MessageType.GetVCard,
        payload: GetVCardPayload(
          id: key,
          fromUsername: _user.username,
          toUsername: username,
        ),
      ),
    );
    ClientResponse resp = await _waitForResponse(key);
    xmpp.VCard vCard = resp.payload as xmpp.VCard;
    return Buddy(
      username: vCard.jabberId ?? username,
      name: vCard.fullName != "null" ? vCard.fullName : null,
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

  Future<void> savePushToken(String pushToken) async {
    String key = _uuid.v1();
    _responseMap[key] = ClientResponse(status: ResponseStatus.Pending);
    _sendPort.send(
      IsolateMessage(
        type: MessageType.SavePushToken,
        payload: SavePushTokenPayload(
          id: key,
          pushToken: pushToken,
        ),
      ),
    );
    await _waitForResponse(key);
  }

  Future<void> onReceiveMessage(ChatMessagePayload chatMessagePayload) async {
    // add to history
    Buddy buddy = await _buddyProvider.get(chatMessagePayload.fromUsername);
    if (buddy == null && _onNewChat != null) {
      // message from unknown user
      _onNewChat(
        chatMessagePayload.fromUsername,
        chatMessagePayload.message,
      );
      return;
    }
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

      case MessageType.GetVCard:
        {
          GetVCardPayload payload = msg.payload;
          String xml = """
            <iq from='${payload.fromUsername}'
                id='${payload.id}'
                to='${payload.toUsername}'
                type='get'>
              <vCard xmlns='vcard-temp'/>
            </iq>""";
          chatClient.sendRawXml(xml);
        }
        break;

      case MessageType.SaveVCard:
        {
          SaveVCardPayload payload = msg.payload;
          String xml = "<iq from='${payload.jabberId}'"
              "id='${payload.id}' type='set'>"
              "<vCard xmlns='vcard-temp'>"
              "<FN>${payload.fullName}</FN>"
              "<PHOTO>"
              "<TYPE>image/png</TYPE>"
              "<BINVAL>${payload.b64ImageData}</BINVAL>"
              "</PHOTO>"
              "<JABBERID>${payload.jabberId}</JABBERID>"
              "</vCard>"
              "</iq>";
          chatClient.sendRawXml(xml);
        }
        break;

      case MessageType.SavePushToken:
        {
          SavePushTokenPayload payload = msg.payload;
          String xml = """
            <iq type="set" id="${payload.id}">
              <query xmlns="jabber:iq:private">
                <blabber xmlns="blabber:devicetoken">
                  <devicetoken>${payload.pushToken}</devicetoken>
                </blabber>
              </query>
            </iq>
          """;
          chatClient.sendRawXml(xml);
        }
        break;

      default:
    }
  });
}

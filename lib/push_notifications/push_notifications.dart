import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';

typedef void NotificationListenerType(
    {String title, String body, dynamic data});

class NotificationsProvider {
  NotificationsProvider._pvtConstructor();
  static NotificationsProvider _instance =
      NotificationsProvider._pvtConstructor();
  factory NotificationsProvider() => _instance;

  FirebaseMessaging _firebaseMessaging;
  String _deviceToken;
  Uuid _uuid = Uuid();
  final Map<String, NotificationListenerType> _listeners = {};

  String get deviceToken => _deviceToken;

  Future<dynamic> _onMesage(Map<String, dynamic> message) async {
    print("Message received: \n"
        "Title=${message['notification']['title']}\n"
        "Body=${message['notification']['body']}\n"
        "Data=${message['data']}");
    _listeners.forEach((_, NotificationListenerType cb) {
      cb(
        title: message["notification"]["title"],
        body: message["notification"]["body"],
        data: message["notification"]["data"],
      );
    });
  }

  void init() async {
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (message) => _onMesage(message),
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _deviceToken = await _firebaseMessaging.getToken();
  }

  Function addListener(NotificationListenerType cb) {
    String uuid = _uuid.v4();
    _listeners[uuid] = cb;
    return () {
      _listeners.remove(uuid);
    };
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  NotificationDetails _platformChannelSpecifics;
  int _localNotifId = 0;
  final Map<String, NotificationListenerType> _listeners = {};

  String get deviceToken => _deviceToken;

  Future<dynamic> _onMessage(Map<String, dynamic> message) async {
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

  Future<void> initPushNotifications() async {
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (message) => _onMessage(message),
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _deviceToken = await _firebaseMessaging.getToken();
  }

  Future<void> initLocalNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings("app_icon");
    IOSInitializationSettings initSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) async {
      print("title=$title\nbody=$body\npayload=$payload");
    });
    InitializationSettings initializationSettings = InitializationSettings(
      initSettingsAndroid,
      initSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (body) async {
        _onMessage({
          "notification": {
            "body": body,
          }
        });
        return true;
      },
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'BLABBER_LOCAL_NOTIFS',
      'Blabber Local Notifications',
      'Blabber Local Notifications',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'Notofication from Blabber',
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    _platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
  }

  Future<void> init() async {
    await Future.wait([
      initPushNotifications(),
      initLocalNotifications(),
    ]);
  }

  Function addListener(NotificationListenerType cb) {
    String uuid = _uuid.v4();
    _listeners[uuid] = cb;
    return () {
      _listeners.remove(uuid);
    };
  }

  Future<void> showLocalNotification({
    String title,
    String body,
    String payload,
  }) async {
    ++_localNotifId;
    await _flutterLocalNotificationsPlugin.show(
      _localNotifId,
      title,
      body,
      _platformChannelSpecifics,
      payload: payload,
    );
  }
}

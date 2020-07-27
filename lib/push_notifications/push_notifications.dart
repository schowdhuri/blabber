import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationManager {
  PushNotificationManager._pvtConstructor();
  static PushNotificationManager _instance =
      PushNotificationManager._pvtConstructor();
  factory PushNotificationManager() => _instance;
  FirebaseMessaging _firebaseMessaging;

  Future<dynamic> _onMesage(Map<String, dynamic> message,
      {BuildContext context}) async {
    if (context == null) {
      print("Message received: \n"
          "Title=${message['notification']['title']}\n"
          "Body=${message['notification']['body']}");
    }
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Column(
          children: [
            Text(
              message['notification']['title'],
            ),
            Text(
              message['notification']['body'],
            ),
          ],
        ),
      ),
    );
  }

  void init({BuildContext context}) {
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (message) => _onMesage(message, context: context),
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }
}

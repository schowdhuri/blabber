import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';

import '../../../models/buddy.dart';
import '../../../notifications/notifications.dart';
import '../../chat/chat_screen.dart';

class NotificationHandler extends HookWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> handleLocalNotification(String body) async {
      print("Local notification opened: $body");
      Map<String, dynamic> data = json.decode(body);
      BuddyProvider buddyProvider = BuddyProvider();
      Buddy sender = await buddyProvider.get(data["fromUsername"]);
      Navigator.of(context).pushNamed(
        "/chat",
        arguments: ChatScreenArgs(
          buddy: sender,
        ),
      );
    }

    void handleNotification({String title, String body, dynamic data}) {
      if (title == null && data == null) {
        handleLocalNotification(body);
        return;
      }
      print("handleNotif: $title");
      Flushbar(
        backgroundColor: Colors.blue[100],
        barBlur: 4,
        borderRadius: 8,
        titleText: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(body),
        margin: EdgeInsets.symmetric(horizontal: 10),
        duration: Duration(seconds: 5),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      ).show(context);
    }

    useEffect(() {
      return Provider.of<NotificationsProvider>(context)
          .addListener(handleNotification);
    }, const []);

    return Container();
  }
}

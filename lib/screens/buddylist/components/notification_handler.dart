import 'dart:convert';
import 'package:chat/screens/new_chat/new_chat_screen.dart';
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
    Future<void> handleNewMessage(String fromUsername) async {
      BuddyProvider buddyProvider = BuddyProvider();
      Buddy sender = await buddyProvider.get(fromUsername);
      Navigator.of(context).pushNamed(
        "/chat",
        arguments: ChatScreenArgs(
          buddy: sender,
        ),
      );
    }

    Future<void> handleNewIncomingChat(
        String fromUsername, String message) async {
      Navigator.of(context).pushNamed(
        "/newchat",
        arguments: NewChatScreenArgs(
          fromUsername,
          message,
        ),
      );
    }

    void handleNotification({String title, String body, dynamic data}) {
      // local notification
      if (title == null && data == null) {
        Map<String, dynamic> data = json.decode(body);
        // local notification: new chat request
        if (data["newChat"] != null) {
          handleNewIncomingChat(
            data["fromUsername"],
            data["message"],
          );
          return;
        }
        // new message
        handleNewMessage(data["fromUsername"]);
      }
      // handle push notification
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

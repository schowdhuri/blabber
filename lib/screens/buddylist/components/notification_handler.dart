import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../../push_notifications/push_notifications.dart';

class NotificationHandler extends HookWidget {
  @override
  Widget build(BuildContext context) {
    void handleNotification({String title, String body, dynamic data}) {
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

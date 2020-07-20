import 'package:chat/screens/buddylist/buddy_list_screen.dart';
import 'package:chat/screens/login_form/login_form_screen.dart';
import 'package:chat/screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == "/") {
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return LoginFormScreen();
        },
      );
    }
    if (settings.name == "/dologin") {
      LoginScreenArgs args = settings.arguments;
      return MaterialPageRoute(builder: (BuildContext context) {
        return LoginScreen(args: args);
      });
    }
    if (settings.name == "/buddylist") {
      BuddyListScreenArgs args = settings.arguments;
      return MaterialPageRoute(builder: (BuildContext context) {
        return BuddyListScreen(args: args);
      });
    }
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return Container(
          child: Text("You shouldn't be here!\n${settings.name}"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: onGenerateRoute,
      initialRoute: "/",
    );
  }
}

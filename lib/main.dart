import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/buddylist/buddy_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/login/login_screen.dart';
import 'chatclient/chat_provider.dart';

void main() async {
  ChatProvider chatProvider = ChatProvider();
  await chatProvider.init();
  // PushNotificationManager pnm = PushNotificationManager();
  // pnm.init();
  runApp(
    Provider.value(
      value: chatProvider,
      child: ChatApp(),
    ),
  );
}

class ChatApp extends StatelessWidget {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == "/") {
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return LoginScreen();
        },
      );
    }
    if (settings.name == "/buddylist") {
      BuddyListScreenArgs args = settings.arguments;
      return MaterialPageRoute(builder: (BuildContext context) {
        return BuddyListScreen(args: args);
      });
    }
    if (settings.name == "/chat") {
      ChatScreenArgs args = settings.arguments;
      return MaterialPageRoute(builder: (BuildContext context) {
        return ChatScreen(args: args);
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

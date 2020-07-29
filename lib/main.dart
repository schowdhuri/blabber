import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'chatclient/chat_provider.dart';
import 'push_notifications/push_notifications.dart';
import 'screens/buddylist/buddy_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/login/login_screen.dart';

void main() async {
  runApp(ChatApp());
}

class ChatApp extends HookWidget {
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
    final ChatProvider chatProvider = ChatProvider();
    final NotificationsProvider notificationsProvider = NotificationsProvider();

    useEffect(() {
      chatProvider.init();
      notificationsProvider.init();
      return () {};
    }, const []);

    return MultiProvider(
      providers: [
        Provider.value(value: chatProvider),
        Provider.value(value: notificationsProvider),
      ],
      child: MaterialApp(
        onGenerateRoute: onGenerateRoute,
        initialRoute: "/",
      ),
    );
  }
}

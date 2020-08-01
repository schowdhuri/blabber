import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'chatclient/chat_provider.dart';
import 'notifications/notifications.dart';
import 'screens/buddylist/buddy_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'store/app_store.dart';

void main() async {
  runApp(ChatApp());
}

class ChatApp extends HookWidget {
  final ChatProvider chatProvider = ChatProvider();
  final NotificationsProvider notificationsProvider = NotificationsProvider();

  Future<void> updateRouteState(
      Store<AppState, DispatchAction> store, RouteSettings settings) async {
    await Future.delayed(Duration(milliseconds: 100));
    store.dispatch(ChangePageAction(
      settings.name,
      settings.arguments,
    ));
  }

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
    if (settings.name == "/profile") {
      return MaterialPageRoute(builder: (BuildContext context) {
        return ProfileScreen();
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
    final Store<AppState, DispatchAction> store = useReducer(
      appReducer,
      initialState: AppState(),
    );

    useEffect(() {
      chatProvider.init();
      notificationsProvider.init();
      return () {};
    }, const []);

    return MultiProvider(
      providers: [
        Provider.value(value: chatProvider),
        Provider.value(value: notificationsProvider),
        Provider.value(value: store),
      ],
      child: MaterialApp(
        onGenerateRoute: (RouteSettings routeSettings) {
          updateRouteState(store, routeSettings);
          return onGenerateRoute(routeSettings);
        },
        initialRoute: "/",
      ),
    );
  }
}

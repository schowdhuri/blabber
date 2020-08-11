import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'chatclient/chat_provider.dart';
import 'notifications/notifications.dart';
import 'store/app_store.dart';
import 'routes.dart';

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
          return AppRoutes.onGenerateRoute(routeSettings);
        },
        initialRoute: "/",
      ),
    );
  }
}

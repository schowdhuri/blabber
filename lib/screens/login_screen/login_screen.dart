import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chat/models/connection_settings.dart';
import 'package:chat/models/user.dart';
import 'package:chat/chatclient/client.dart';
import 'package:chat/screens/buddylist/buddy_list_screen.dart';

class LoginScreen extends HookWidget {
  final LoginScreenArgs args;
  const LoginScreen({Key key, @required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isConnected = useState(false);
    ValueNotifier<ChatClient> chatClient = useState(
      ChatClient(
        host: args.connectionSettings.host,
        port: args.connectionSettings.port,
        userAtDomain: args.user.username,
        password: args.user.password,
        onMessageReceived: (String msg) {
          // messages.value = [...messages.value, msg];
          // print(messages.value.toList());
        },
      ),
    );
    // ValueNotifier<ChatClient> chatClient = useState(
    //   ChatClient(
    //     host: "192.168.29.177",
    //     port: 5222,
    //     userAtDomain: "user1@xmpp1.ddplabs.com",
    //     password: "user1",
    //     onMessageReceived: (String msg) {
    //       // messages.value = [...messages.value, msg];
    //       // print(messages.value.toList());
    //     },
    //   ),
    // );
    useEffect(() {
      try {
        chatClient.value.connect();
        isConnected.value = true;
      } catch (ex0) {
        print("Uh oh ${ex0.toString()}");
      }
      return () {};
    }, const []);

    useEffect(() {
      if (isConnected.value) {
        Navigator.pushNamed(
          context,
          "/buddylist",
          arguments: BuddyListScreenArgs(chatClient: chatClient.value),
        );
      }
      return () {};
    }, [isConnected.value]);

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoginScreenArgs {
  final ConnectionSettings connectionSettings;
  final User user;

  const LoginScreenArgs({
    @required this.connectionSettings,
    @required this.user,
  });
}

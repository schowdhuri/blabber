import 'package:chat/chatclient/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<String>> messages = useState([]);
    ValueNotifier<ChatClient> chatClient = useState(
      ChatClient(
        host: "192.168.29.177",
        port: 5222,
        userAtDomain: "user1@xmpp1.ddplabs.com",
        password: "user1",
        onMessageReceived: (String msg) {
          messages.value = [...messages.value, msg];
          print(messages.value.toList());
        },
      ),
    );
    useEffect(() {
      chatClient.value.connect();
      return () {};
    }, const []);

    return MaterialApp(
      title: "Chat",
      home: Scaffold(
        body: ChatPage(
          messages: messages.value,
          onSend: (String msg) {
            chatClient.value.sendMessage(
              "user2@xmpp1.ddplabs.com",
              msg,
            );
          },
        ),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final List<String> messages;
  final Function onSend;

  const ChatPage({
    Key key,
    @required this.messages,
    @required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          SizedBox(
            height: height * 0.8,
            child: Column(
              children: [
                for (String msg in messages)
                  ListTile(
                    title: Text(
                      msg,
                    ),
                  )
              ],
            ),
          ),
          Container(
            child: TextField(
              onSubmitted: onSend,
              decoration: InputDecoration(
                hintText: "Type a message",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

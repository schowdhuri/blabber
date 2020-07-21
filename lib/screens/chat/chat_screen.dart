import 'package:chat/chatclient/client.dart';
import 'package:chat/models/buddy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ChatScreen extends HookWidget {
  final ChatScreenArgs args;

  const ChatScreen({this.args});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<String>> messages = useState([]);

    handleReceive(String message) {
      print("handleReceive: $message");
      messages.value = [...messages.value, message];
    }

    handleSend(String message) {
      args.chatClient.sendMessage(
        args.buddy.username,
        message,
      );
      messages.value = [...messages.value, message];
    }

    useEffect(() {
      args.chatClient.addMessageListener(handleReceive);
      return () {};
    }, const []);

    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          args.buddy.username,
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: height * 0.8,
              child: Column(
                children: [
                  for (String msg in messages.value)
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
                onSubmitted: handleSend,
                decoration: InputDecoration(
                  hintText: "Type a message",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreenArgs {
  final ChatClient chatClient;
  final Buddy buddy;
  ChatScreenArgs({this.chatClient, this.buddy});
}

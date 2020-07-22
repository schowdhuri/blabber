import 'package:chat/screens/chat/components/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../chatclient/client.dart';
import '../../models/buddy.dart';
import '../../models/chat_message.dart';
import 'components/chat_input.dart';

class ChatScreen extends HookWidget {
  final ChatScreenArgs args;

  const ChatScreen({this.args});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<ChatMessage>> messages = useState([]);
    ValueNotifier<ScrollController> scrollController =
        useState(ScrollController());

    void handleReceive(String message) async {
      messages.value = <ChatMessage>[
        ...messages.value,
        ChatMessage(
          from: args.buddy,
          text: message,
          timestamp: DateTime.now(),
        ),
      ];
      await Future.delayed(Duration(milliseconds: 500));
      scrollController.value.animateTo(
        scrollController.value.position.maxScrollExtent,
        duration: Duration(milliseconds: 250),
        curve: Curves.linear,
      );
    }

    void handleSend(String message) async {
      args.chatClient.sendMessage(
        args.buddy.username,
        message,
      );
      messages.value = [
        ...messages.value,
        ChatMessage(
          to: args.buddy,
          text: message,
          timestamp: DateTime.now(),
        ),
      ];
      await Future.delayed(Duration(milliseconds: 250));
      scrollController.value.animateTo(
        scrollController.value.position.maxScrollExtent,
        duration: Duration(milliseconds: 250),
        curve: Curves.linear,
      );
    }

    bool isContinued(int index) {
      if (index == 0) {
        return false;
      }
      if ((messages.value[index - 1].from == null &&
              messages.value[index].from != null) ||
          (messages.value[index - 1].from != null &&
              messages.value[index].from == null)) {
        return false;
      }
      return (messages.value[index - 1].from == null &&
              messages.value[index].from == null) ||
          (messages.value[index - 1].from.username ==
              messages.value[index].from.username);
    }

    useEffect(() {
      args.chatClient.addMessageListener(handleReceive);
      return () {};
    }, const []);

    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xffeceff1),
      appBar: AppBar(
        title: Text(
          args.buddy.username,
        ),
      ),
      body: SizedBox(
        height: height,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController.value,
                itemCount: messages.value.length,
                itemBuilder: (BuildContext _, int index) {
                  return ChatBubble(
                    messages.value[index],
                    isContinued: isContinued(index),
                  );
                },
              ),
            ),
            ChatInput(onSend: handleSend),
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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/chat_history.dart';
import '../../chatclient/chat_provider.dart';
import '../../models/buddy.dart';
import '../../models/chat_message.dart';
import 'components/chat_bubble.dart';
import 'components/chat_input.dart';

class ChatScreen extends HookWidget {
  final ChatScreenArgs args;

  const ChatScreen({this.args});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<ChatMessage>> messages = useState([]);
    ValueNotifier<ScrollController> scrollController =
        useState(ScrollController());

    Future<void> scrollToBottom() async {
      await Future.delayed(Duration(milliseconds: 250));
      scrollController.value.animateTo(
        0,
        duration: Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    }

    Future<void> markAllRead() async {
      ChatHistoryProvider chProvider = ChatHistoryProvider();
      await chProvider.markAllRead(args.buddy);
    }

    Future<void> getChatHistory() async {
      ChatHistoryProvider chProvider = ChatHistoryProvider();
      ChatHistory chatHistory = await chProvider.get(args.buddy);
      if (chatHistory != null) {
        messages.value = chatHistory.getChatMessages(args.buddy);
      }
    }

    void handleReceive(String message,
        {String fromUsername, String toUsername, bool isReceived}) async {
      if (!isReceived || fromUsername != args.buddy.username) {
        return;
      }
      ChatMessage chatMessage = ChatMessage(
        from: args.buddy,
        text: message,
        timestamp: DateTime.now(),
      );
      messages.value = <ChatMessage>[
        ...messages.value,
        chatMessage,
      ];
      scrollToBottom();
      markAllRead();
    }

    Future<void> handleSend(String message) async {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(
        args.buddy.username,
        message,
      );
      ChatMessage chatMessage = ChatMessage(
        to: args.buddy,
        text: message,
        timestamp: DateTime.now(),
      );
      messages.value = [
        ...messages.value,
        chatMessage,
      ];
    }

    Future<void> handleUpload(
        {String filePath, String contentType, int length}) async {
      ChatMessage chatMessage =
          await Provider.of<ChatProvider>(context, listen: false).sendFile(
        args.buddy.username,
        filePath,
        contentType,
        length,
      );
      if (chatMessage == null) {
        return;
      }
      messages.value = [
        ...messages.value,
        chatMessage,
      ];
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
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      Function removeMessageListener = chatProvider.addMessageListener(
        handleReceive,
      );
      getChatHistory();
      markAllRead();
      return removeMessageListener;
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
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (BuildContext _, int index) {
                  return ChatBubble(
                    messages.value[messages.value.length - index - 1],
                    isContinued: isContinued(messages.value.length - index - 1),
                  );
                },
              ),
            ),
            ChatInput(
              onSend: handleSend,
              onUpload: handleUpload,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreenArgs {
  final Buddy buddy;
  ChatScreenArgs({this.buddy});
}

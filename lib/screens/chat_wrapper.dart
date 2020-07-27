import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../chatclient/chat_provider.dart';
import '../models/buddy.dart';
import '../models/chat_history.dart';
import '../models/chat_message.dart';
import 'buddylist/buddy_list_screen.dart';
import 'chat/chat_screen.dart';

class ChatWrapper extends HookWidget {
  final BuddyListScreenArgs buddyListScreenArgs;
  final ChatScreenArgs chatScreenArgs;

  ChatWrapper({
    this.buddyListScreenArgs,
    this.chatScreenArgs,
  });

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Buddy>> buddies = useState([]);
    ValueNotifier<Map<String, ChatMessage>> latestMessage = useState({});

    Future<void> getLatestMessages() async {
      ChatHistoryProvider historyProvider = new ChatHistoryProvider();
      List<Future<ChatMessage>> fArr =
          buddies.value.map(historyProvider.getLatestMessage).toList();
      List<ChatMessage> _chatMessages = await Future.wait(fArr);
      Map<String, ChatMessage> _latestMessages = {};
      _chatMessages.forEach((ChatMessage _chatMessage) {
        Buddy _buddy = _chatMessage.from ?? _chatMessage.to;
        _latestMessages[_buddy.username] = _chatMessage;
      });
      latestMessage.value = _latestMessages;
    }

    Future<void> loadBuddies() async {
      BuddyProvider buddyProvider = BuddyProvider();
      List<Buddy> _buddies = await buddyProvider.getAll();
      buddies.value = _buddies;
      await getLatestMessages();
    }

    Future<void> handleMessage(String message,
        {String fromUsername, String toUsername, bool isReceived}) async {
      BuddyProvider buddyProvider = BuddyProvider();
      Buddy buddy = await buddyProvider.get(fromUsername);
      latestMessage.value = {
        ...latestMessage.value,
        buddy.username: ChatMessage(
          from: isReceived ? buddy : null,
          to: isReceived ? null : buddy,
          timestamp: DateTime.now(),
          text: message,
        ),
      };
    }

    void handleAddBuddy(Buddy buddy) {
      buddies.value = [...buddies.value, buddy];
    }

    void handleUpdateBuddies(List<Buddy> _buddies) {
      buddies.value = _buddies;
    }

    useEffect(() {
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      Function removeMessageListener = chatProvider.addMessageListener(
        handleMessage,
      );
      loadBuddies();
      return removeMessageListener;
    }, const []);

    return buddyListScreenArgs != null
        ? BuddyListScreen(
            args: buddyListScreenArgs,
            buddies: buddies.value,
            latestMessage: latestMessage.value,
            onAddBuddy: handleAddBuddy,
            onUpdateBuddies: handleUpdateBuddies,
          )
        : ChatScreen(
            args: chatScreenArgs,
          );
  }
}

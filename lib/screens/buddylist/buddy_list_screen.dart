import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../chatclient/chat_provider.dart';
import '../../push_notifications/push_notifications.dart';
import '../../models/chat_history.dart';
import '../../models/chat_message.dart';
import '../../models/buddy.dart';
import '../chat/chat_screen.dart';
import 'components/add_buddy.dart';
import 'components/buddy_row.dart';
import 'components/buddy_row_edit.dart';
import 'components/notification_handler.dart';
import 'components/actions_menu.dart';

class BuddyListScreen extends HookWidget {
  final BuddyListScreenArgs args;

  const BuddyListScreen({Key key, @required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Buddy>> buddies = useState([]);
    ValueNotifier<Map<String, ChatMessage>> latestMessage = useState({});
    ValueNotifier<bool> isEditMode = useState(false);
    ValueNotifier<List<Buddy>> selectedBuddies = useState([]);
    ValueNotifier<Map<String, int>> unreadCounts = useState({});

    handleAdd(String username) async {
      BuddyProvider buddyProvider = BuddyProvider();
      Buddy buddy = await buddyProvider.add(
        Buddy(
          username: username,
        ),
      );
      buddies.value = [...buddies.value, buddy];
    }

    handleDelete(BuildContext context) => () async {
          BuddyProvider buddyProvider = BuddyProvider();
          List<Future> fArr = selectedBuddies.value
              .map(
                (Buddy b) => buddyProvider.remove(b),
              )
              .toList();
          await Future.wait(fArr);
          buddies.value.removeWhere(
            (Buddy b) => selectedBuddies.value.indexOf(b) >= 0,
          );
          Navigator.of(context).pop();
        };

    showForm() {
      showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: true,
        child: AddBuddy(onAdd: handleAdd),
      );
    }

    handleOpenChat(Buddy buddy) {
      Navigator.of(context).pushNamed(
        "/chat",
        arguments: ChatScreenArgs(buddy: buddy),
      );
    }

    handleOpenEditMode(List<Buddy> initSelected) {
      isEditMode.value = true;
      selectedBuddies.value = initSelected;
      ModalRoute.of(context).addLocalHistoryEntry(
        LocalHistoryEntry(
          onRemove: () {
            isEditMode.value = false;
          },
        ),
      );
    }

    handleChangeSelection(Buddy buddy, bool isSelected) {
      if (isSelected) {
        selectedBuddies.value = [...selectedBuddies.value, buddy];
      } else {
        int index = selectedBuddies.value.indexOf(buddy);
        selectedBuddies.value = [
          ...selectedBuddies.value.sublist(0, index),
          ...selectedBuddies.value.sublist(index + 1),
        ];
      }
    }

    Future<void> getLatestMessages() async {
      ChatHistoryProvider historyProvider = new ChatHistoryProvider();
      List<Future<ChatMessage>> fArr =
          buddies.value.map(historyProvider.getLatestMessage).toList();
      List<ChatMessage> _chatMessages = await Future.wait(fArr);
      Map<String, ChatMessage> _latestMessages = {};
      _chatMessages.forEach((ChatMessage _chatMessage) {
        if (_chatMessage == null) {
          return;
        }
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

    handleMessage(String message,
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

    Timer getUnreadCounts() {
      return Timer.periodic(Duration(seconds: 5), (_) async {
        ChatHistoryProvider historyProvider = new ChatHistoryProvider();
        List<Future<int>> fArr =
            buddies.value.map(historyProvider.getUnreadCount).toList();
        List<int> counts = await Future.wait(fArr);
        Map<String, int> _unreadCounts = {};
        for (int index = 0; index < counts.length; index++) {
          _unreadCounts[buddies.value[index].username] = counts[index];
        }
        unreadCounts.value = _unreadCounts;
      });
    }

    void saveDeviceToken() {
      String pushToken =
          Provider.of<NotificationsProvider>(context, listen: false)
              .deviceToken;
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      chatProvider.savePushToken(pushToken);
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

    useEffect(() {
      Timer timer = getUnreadCounts();
      return timer.cancel;
    }, const []);

    useEffect(() {
      saveDeviceToken();
      return () {};
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: isEditMode.value ? null : Text("Buddies"),
        actions: [
          isEditMode.value
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: handleDelete(context),
                )
              : ActionsMenu(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return isEditMode.value
                    ? BuddyRowEditable(
                        buddy: buddies.value[index],
                        onChangeSelection: handleChangeSelection,
                        isSelected: selectedBuddies.value
                                .indexOf(buddies.value[index]) >=
                            0)
                    : BuddyRow(
                        buddy: buddies.value[index],
                        latestMessage:
                            latestMessage.value[buddies.value[index].username],
                        unreadCount:
                            unreadCounts.value[buddies.value[index].username],
                        onOpenChat: handleOpenChat,
                        onOpenEditMode: handleOpenEditMode,
                      );
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: buddies.value.length,
            ),
          ),
          NotificationHandler(),
        ],
      ),
      floatingActionButton: isEditMode.value
          ? null
          : FloatingActionButton(
              onPressed: showForm,
              child: Icon(Icons.add),
            ),
    );
  }
}

class BuddyListScreenArgs {}

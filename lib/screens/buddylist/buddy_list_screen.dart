import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../chatclient/chat_provider.dart';
import '../../notifications/notifications.dart';
import '../../models/chat_history.dart';
import '../../models/chat_message.dart';
import '../../models/buddy.dart';
import '../../store/app_store.dart';
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
    ValueNotifier<bool> isEditMode = useState(false);
    ValueNotifier<List<Buddy>> selectedBuddies = useState([]);
    AppState appState =
        Provider.of<Store<AppState, DispatchAction>>(context).state;

    handleAdd(String username) async {
      BuddyProvider buddyProvider = BuddyProvider();
      Buddy buddy = await buddyProvider.add(
        Buddy(
          username: username,
        ),
      );
      Provider.of<Store<AppState, DispatchAction>>(context, listen: false)
          .dispatch(AddBuddyAction(buddy));
    }

    handleDelete(BuildContext context) => () async {
          BuddyProvider buddyProvider = BuddyProvider();
          List<Future> fArr = selectedBuddies.value
              .map(
                (Buddy b) => buddyProvider.remove(b),
              )
              .toList();
          await Future.wait(fArr);
          Provider.of<Store<AppState, DispatchAction>>(context, listen: false)
              .dispatch(RemoveBuddiesAction(selectedBuddies.value));
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
      Store<AppState, DispatchAction> store =
          Provider.of<Store<AppState, DispatchAction>>(context, listen: false);
      List<Future<ChatMessage>> fArr =
          store.state.buddies.map(historyProvider.getLatestMessage).toList();
      List<ChatMessage> _chatMessages = await Future.wait(fArr);
      Map<String, ChatMessage> _latestMessages = {};
      _chatMessages.forEach((ChatMessage _chatMessage) {
        if (_chatMessage == null) {
          return;
        }
        Buddy _buddy = _chatMessage.from ?? _chatMessage.to;
        _latestMessages[_buddy.username] = _chatMessage;
      });
      store.dispatch(UpdateLatestMessagesAction(_latestMessages));
    }

    Future<List<Buddy>> getBuddyProfiles(List<Buddy> _buddies) async {
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      List<Future<Buddy>> futures =
          _buddies.map(chatProvider.getBuddyProfile).toList();
      _buddies = await Future.wait(futures);
      return _buddies;
    }

    Future<void> loadBuddies() async {
      BuddyProvider buddyProvider = BuddyProvider();
      List<Buddy> _buddies =
          await buddyProvider.getAll().then(getBuddyProfiles);
      Store<AppState, DispatchAction> store =
          Provider.of<Store<AppState, DispatchAction>>(context, listen: false);
      store.dispatch(UpdateBuddiesAction(_buddies));
      await getLatestMessages();
    }

    void sendLocalNotification(Buddy buddy, String message) {
      AppState state = Provider.of<Store<AppState, DispatchAction>>(
        context,
        listen: false,
      ).state;
      if (state.path == "/chat") {
        ChatScreenArgs args = state.pathArgs;
        if (args.buddy.username == buddy.username) {
          return;
        }
      }
      Provider.of<NotificationsProvider>(context, listen: false)
          .showLocalNotification(
        title: "${buddy.friendlyName}",
        body: message,
        payload: json.encode({
          "fromUsername": buddy.username,
          "message": message,
        }),
      );
    }

    Future<void> handleNewIncomingChat(
        String fromUsername, String message) async {
      Provider.of<NotificationsProvider>(context, listen: false)
          .showLocalNotification(
        title: "New chat request",
        body: message,
        payload: json.encode({
          "fromUsername": fromUsername,
          "message": message,
          "newChat": true,
        }),
      );
    }

    Future<void> handleMessage(String message,
        {String fromUsername, String toUsername, bool isReceived}) async {
      BuddyProvider buddyProvider = BuddyProvider();
      Buddy buddy = await buddyProvider.get(fromUsername);
      Store<AppState, DispatchAction> store =
          Provider.of<Store<AppState, DispatchAction>>(context, listen: false);
      store.dispatch(
        UpdateLatestMessageAction(
          buddy.username,
          ChatMessage(
            from: isReceived ? buddy : null,
            to: isReceived ? null : buddy,
            timestamp: DateTime.now(),
            text: message,
          ),
        ),
      );

      if (isReceived) {
        sendLocalNotification(buddy, message);
      }
    }

    Timer getUnreadCounts() {
      return Timer.periodic(Duration(seconds: 5), (_) async {
        Store<AppState, DispatchAction> store =
            Provider.of<Store<AppState, DispatchAction>>(context,
                listen: false);
        ChatHistoryProvider historyProvider = new ChatHistoryProvider();
        List<Future<int>> fArr =
            store.state.buddies.map(historyProvider.getUnreadCount).toList();
        List<int> counts = await Future.wait(fArr);
        Map<String, int> _unreadCounts = {};
        for (int index = 0; index < counts.length; index++) {
          _unreadCounts[store.state.buddies[index].username] = counts[index];
        }
        store.dispatch(UpdateUnreadCountsAction(_unreadCounts));
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

    // Listen for messages from unknown senders
    useEffect(() {
      return Provider.of<ChatProvider>(context, listen: false)
          .addNewChatListener(handleNewIncomingChat);
    }, const []);

    // Listen for new messages
    useEffect(() {
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      Function removeMessageListener = chatProvider.addMessageListener(
        handleMessage,
      );
      return removeMessageListener;
    }, const []);

    // Load buddy list
    useEffect(() {
      loadBuddies();
      return () {};
    }, const []);

    // Get unread counts
    useEffect(() {
      Timer timer = getUnreadCounts();
      return timer.cancel;
    }, const []);

    // Send pushToken to server
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
                        buddy: appState.buddies[index],
                        onChangeSelection: handleChangeSelection,
                        isSelected: selectedBuddies.value
                                .indexOf(appState.buddies[index]) >=
                            0)
                    : BuddyRow(
                        buddy: appState.buddies[index],
                        latestMessage: appState
                            .latestMessage[appState.buddies[index].username],
                        unreadCount: appState
                            .unreadCounts[appState.buddies[index].username],
                        onOpenChat: handleOpenChat,
                        onOpenEditMode: handleOpenEditMode,
                      );
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: appState.buddies.length,
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

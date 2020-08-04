import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/chat_history.dart';
import '../../models/chat_message.dart';
import '../../models/buddy.dart';
import '../../chatclient/chat_provider.dart';
import '../../store/app_store.dart';
import '../chat/chat_screen.dart';
import '../profile/components/profile_image.dart';
import 'components/action_buttons.dart';
import 'components/intro.dart';

class NewChatScreen extends HookWidget {
  final NewChatScreenArgs args;

  NewChatScreen({this.args, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Buddy> buddy = useState();

    double width = MediaQuery.of(context).size.width;

    Future<void> addToHistory(Buddy buddy, String message) async {
      ChatHistoryProvider chatHistoryProvider = ChatHistoryProvider();
      return chatHistoryProvider.add(
        buddy,
        ChatMessage(
          from: buddy,
          text: message,
          isRead: false,
        ),
      );
    }

    Future<void> handleAccept() async {
      BuddyProvider buddyProvider = BuddyProvider();
      Buddy _buddy = await buddyProvider.add(buddy.value);
      Store<AppState, DispatchAction> store =
          Provider.of<Store<AppState, DispatchAction>>(context, listen: false);
      store.dispatch(
        AddBuddyAction(
          _buddy,
          messages: [
            ChatMessage(
              from: _buddy,
              isRead: false,
              text: args.message,
            ),
          ],
        ),
      );
      await addToHistory(_buddy, args.message);
      Navigator.of(context).pushReplacementNamed(
        "/chat",
        arguments: ChatScreenArgs(buddy: _buddy),
      );
    }

    void handleIgnore() {
      Navigator.of(context).pop();
    }

    useEffect(() {
      Provider.of<ChatProvider>(context, listen: false)
          .getProfileByUsername(args.username)
          .then((value) => buddy.value = value);
      return () {};
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text("You have a new chat request"),
      ),
      body: buddy.value == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 30),
                ProfileImage(
                  user: buddy.value,
                ),
                SizedBox(height: 30),
                Intro(
                  width: width,
                  buddy: buddy.value,
                  args: args,
                ),
                Spacer(),
                ActionButtons(
                  handleAccept: handleAccept,
                  handleIgnore: handleIgnore,
                ),
              ],
            ),
    );
  }
}

class NewChatScreenArgs {
  final String username;
  final String message;
  NewChatScreenArgs(this.username, this.message);
}

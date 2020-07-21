import 'package:chat/models/buddy.dart';
import 'package:chat/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chat/chatclient/client.dart';

class BuddyListScreen extends HookWidget {
  final BuddyListScreenArgs args;
  const BuddyListScreen({Key key, @required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Buddy>> buddies = useState([]);

    handleAdd(String username) async {
      BuddyProvider buddyProvider = BuddyProvider();
      Buddy buddy = await buddyProvider.add(
        Buddy(
          username: username,
        ),
      );
      buddies.value = [...buddies.value, buddy];
    }

    handleDelete(Buddy buddy) => () async {
          BuddyProvider buddyProvider = BuddyProvider();
          await buddyProvider.remove(buddy);
          int index = buddies.value.indexOf(buddy);
          buddies.value = [
            ...buddies.value.sublist(0, index),
            ...buddies.value.sublist(index + 1),
          ];
        };

    showForm() {
      showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: true,
        child: AddBuddy(onAdd: handleAdd),
      );
    }

    loadBuddies() async {
      BuddyProvider buddyProvider = BuddyProvider();
      buddies.value = await buddyProvider.getAll();
    }

    handleOpenChat(Buddy buddy) => () {
          Navigator.of(context).pushNamed(
            "/chat",
            arguments: ChatScreenArgs(
              buddy: buddy,
              chatClient: args.chatClient,
            ),
          );
        };

    useEffect(() {
      loadBuddies();
      return () {};
    }, const []);

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text("Buddies"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showForm,
          )
        ],
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: handleOpenChat(buddies.value[index]),
            leading: Icon(Icons.person_outline),
            title: Text(buddies.value[index].username),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: handleDelete(
                buddies.value[index],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(),
        itemCount: buddies.value.length,
      ),
    );
  }
}

class AddBuddy extends HookWidget {
  final Function onAdd;
  const AddBuddy({
    Key key,
    this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String> username = useState("");
    handleCancel() {
      Navigator.of(context).pop();
    }

    addBuddy() {
      if (username.value.isEmpty) {
        return;
      }
      onAdd(username.value);
      Navigator.of(context).pop();
    }

    return AlertDialog(
      content: TextField(
        decoration: InputDecoration(
          labelText: "Username",
          hintText: "eg: user2@xmpp1.ddplabs.com",
        ),
        onSubmitted: (String val) {
          username.value = val;
          addBuddy();
        },
      ),
      actions: [
        FlatButton(
          onPressed: handleCancel,
          child: Text("CANCEL"),
        ),
        FlatButton(
          onPressed: addBuddy,
          child: Text(
            "ADD",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class BuddyListScreenArgs {
  final ChatClient chatClient;

  const BuddyListScreenArgs({
    @required this.chatClient,
  });
}

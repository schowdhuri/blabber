import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../chatclient/client.dart';
import '../../models/buddy.dart';
import '../chat/chat_screen.dart';
import 'components/add_buddy.dart';
import './components/buddy_row.dart';
import './components/buddy_row_edit.dart';

class BuddyListScreen extends HookWidget {
  final BuddyListScreenArgs args;
  const BuddyListScreen({Key key, @required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Buddy>> buddies = useState([]);
    ValueNotifier<bool> isEditMode = useState(false);
    ValueNotifier<List<Buddy>> selectedBuddies = useState([]);
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
          print(selectedBuddies.value);
          BuddyProvider buddyProvider = BuddyProvider();
          List<Future> fArr = selectedBuddies.value
              .map(
                (Buddy b) => buddyProvider.remove(b),
              )
              .toList();
          await Future.wait(fArr);
          List<Buddy> _buddies = buddies.value;
          _buddies.removeWhere(
            (Buddy b) => selectedBuddies.value.indexOf(b) >= 0,
          );
          buddies.value = _buddies;
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

    useEffect(() {
      loadBuddies();
      return () {};
    }, const []);

    return Scaffold(
      appBar: AppBar(
        leading: isEditMode.value ? null : Container(),
        title: Text("Buddies"),
        actions: [
          isEditMode.value
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: handleDelete(context),
                )
              : IconButton(
                  icon: Icon(Icons.add),
                  onPressed: showForm,
                )
        ],
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return isEditMode.value
              ? BuddyRowEditable(
                  buddy: buddies.value[index],
                  onChangeSelection: handleChangeSelection,
                  isSelected:
                      selectedBuddies.value.indexOf(buddies.value[index]) >= 0)
              : BuddyRow(
                  buddy: buddies.value[index],
                  onOpenChat: handleOpenChat,
                  onOpenEditMode: handleOpenEditMode,
                );
        },
        separatorBuilder: (_, __) => Divider(),
        itemCount: buddies.value.length,
      ),
    );
  }
}

class BuddyListScreenArgs {
  final ChatClient chatClient;

  const BuddyListScreenArgs({
    @required this.chatClient,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/chat_message.dart';
import '../../models/buddy.dart';
import '../chat/chat_screen.dart';
import 'components/add_buddy.dart';
import 'components/buddy_row.dart';
import 'components/buddy_row_edit.dart';

class BuddyListScreen extends HookWidget {
  final List<Buddy> buddies;
  final Map<String, ChatMessage> latestMessage;
  final BuddyListScreenArgs args;
  final Function onAddBuddy;
  final Function onUpdateBuddies;

  const BuddyListScreen({
    Key key,
    @required this.args,
    this.buddies,
    this.latestMessage,
    this.onAddBuddy,
    this.onUpdateBuddies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isEditMode = useState(false);
    ValueNotifier<List<Buddy>> selectedBuddies = useState([]);

    handleAdd(String username) async {
      BuddyProvider buddyProvider = BuddyProvider();
      Buddy buddy = await buddyProvider.add(
        Buddy(
          username: username,
        ),
      );
      onAddBuddy(buddy);
    }

    handleDelete(BuildContext context) => () async {
          BuddyProvider buddyProvider = BuddyProvider();
          List<Future> fArr = selectedBuddies.value
              .map(
                (Buddy b) => buddyProvider.remove(b),
              )
              .toList();
          await Future.wait(fArr);
          buddies.removeWhere(
            (Buddy b) => selectedBuddies.value.indexOf(b) >= 0,
          );
          onUpdateBuddies(buddies);
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
                  buddy: buddies[index],
                  onChangeSelection: handleChangeSelection,
                  isSelected:
                      selectedBuddies.value.indexOf(buddies[index]) >= 0)
              : BuddyRow(
                  buddy: buddies[index],
                  latestMessage: latestMessage[buddies[index].username],
                  onOpenChat: handleOpenChat,
                  onOpenEditMode: handleOpenEditMode,
                );
        },
        separatorBuilder: (_, __) => Divider(),
        itemCount: buddies.length,
      ),
    );
  }
}

class BuddyListScreenArgs {}

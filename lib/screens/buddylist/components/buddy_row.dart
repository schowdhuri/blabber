import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/buddy.dart';
import '../../../models/chat_message.dart';

class BuddyRow extends StatelessWidget {
  final Function onOpenChat;
  final Function onOpenEditMode;
  final Buddy buddy;
  final ChatMessage latestMessage;
  final _dateFormat = DateFormat("HH:mm");

  BuddyRow({
    Key key,
    this.onOpenChat,
    this.onOpenEditMode,
    this.buddy,
    this.latestMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () {
        onOpenEditMode([buddy]);
      },
      onTap: () {
        onOpenChat(buddy);
      },
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.person_outline,
          color: Colors.blueGrey,
        ),
        radius: 32,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(buddy.friendlyName),
          latestMessage != null
              ? Text(
                  _dateFormat.format(latestMessage.timestamp),
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 14,
                  ),
                )
              : Container(),
        ],
      ),
      subtitle: latestMessage != null
          ? Text(
              "${latestMessage.from == null ? 'You: ' : ""}${latestMessage.text}",
              softWrap: false,
            )
          : Container(),
    );
  }
}

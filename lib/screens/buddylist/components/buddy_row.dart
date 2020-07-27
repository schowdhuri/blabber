import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/buddy.dart';
import '../../../models/chat_message.dart';

class BuddyRow extends StatelessWidget {
  final Function onOpenChat;
  final Function onOpenEditMode;
  final Buddy buddy;
  final ChatMessage latestMessage;
  final int unreadCount;
  final _dateFormat = DateFormat("HH:mm");

  BuddyRow({
    Key key,
    this.onOpenChat,
    this.onOpenEditMode,
    this.buddy,
    this.latestMessage,
    this.unreadCount,
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
                    fontSize: 12,
                  ),
                )
              : Container(),
        ],
      ),
      subtitle: latestMessage != null
          ? Row(
              children: [
                Text(
                  "${latestMessage.from == null ? 'You: ' : ""}${latestMessage.text}",
                  softWrap: false,
                ),
                Spacer(),
                unreadCount != null && unreadCount > 0
                    ? Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$unreadCount",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Container(),
              ],
            )
          : Container(),
    );
  }
}

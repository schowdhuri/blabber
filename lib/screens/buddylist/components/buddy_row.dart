import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../models/buddy.dart';

class BuddyRow extends HookWidget {
  final Function onOpenChat;
  final Function onOpenEditMode;
  final Buddy buddy;

  BuddyRow({
    Key key,
    this.onOpenChat,
    this.onOpenEditMode,
    this.buddy,
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
      leading: Icon(Icons.person_outline),
      title: Text(buddy.username),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.blueGrey,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum _Action {
  EditProfile,
  Preferences,
}

class ActionsMenu extends HookWidget {
  @override
  Widget build(BuildContext context) {
    handleSelect(_Action action) {
      switch (action) {
        case _Action.EditProfile:
          Navigator.of(context).pushNamed("/profile");
          // updateAvatar();
          break;

        case _Action.Preferences:
          // getMyVCard();
          break;

        default:
      }
    }

    return PopupMenuButton(
      offset: Offset(0, 80),
      onSelected: handleSelect,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _Action.EditProfile,
          child: Text("Edit Profile"),
        ),
        PopupMenuItem(
          value: _Action.Preferences,
          child: Text("Preferences"),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../models/buddy.dart';

class BuddyRowEditable extends HookWidget {
  final Function onChangeSelection;
  final Buddy buddy;
  final bool isSelected;

  BuddyRowEditable({
    Key key,
    this.onChangeSelection,
    this.buddy,
    this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      onChanged: (bool val) {
        onChangeSelection(buddy, val);
      },
      value: isSelected,
      title: Text(buddy.username),
    );
  }
}

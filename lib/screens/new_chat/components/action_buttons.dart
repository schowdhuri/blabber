import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final Function handleIgnore, handleAccept;
  const ActionButtons({
    Key key,
    this.handleIgnore,
    this.handleAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: FlatButton(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(vertical: 32),
            onPressed: handleIgnore,
            child: Text(
              "IGNORE",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
        Expanded(
          child: FlatButton(
            color: Colors.blueGrey[100],
            padding: EdgeInsets.symmetric(vertical: 32),
            onPressed: handleAccept,
            child: Text(
              "ACCEPT",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../models/buddy.dart';
import '../new_chat_screen.dart';

class Intro extends StatelessWidget {
  const Intro({
    Key key,
    @required this.width,
    @required this.buddy,
    @required this.args,
  }) : super(key: key);

  final double width;
  final Buddy buddy;
  final NewChatScreenArgs args;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(32),
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(4),
        ),
        color: Colors.blueGrey[50],
      ),
      // margin: EdgeInsets.symmetric(horizontal: 40),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan(
            text: buddy.friendlyName,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: " says:\n\n",
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: args.message,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 18,
            ),
          ),
        ]),
      ),
    );
  }
}

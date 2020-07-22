import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ChatInput extends HookWidget {
  final Function onSend;
  const ChatInput({
    Key key,
    this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<TextEditingController> txtController =
        useState(TextEditingController());

    handleSend(String message) {
      message = message.trim();
      if (message.isEmpty) {
        return;
      }
      onSend(message);
      txtController.value.clear();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16, 4, 0, 4),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: txtController.value,
              onSubmitted: handleSend,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              handleSend(txtController.value.text);
            },
            icon: Icon(
              Icons.send,
              size: 18,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}

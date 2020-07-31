import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../../models/chat_message.dart';

class ChatBubble extends HookWidget {
  final ChatMessage message;
  final bool isContinued;
  final DateFormat _dateFormatter = DateFormat('HH:mm');

  ChatBubble(this.message, {this.isContinued = false});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> sent = useState(message.from == null);
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment:
          sent.value ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: width * 0.1,
            maxWidth: width * 0.5,
          ),
          margin: EdgeInsets.fromLTRB(
            16,
            isContinued ? 1 : 20,
            16,
            0,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          decoration: sent.value
              ? BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(
                    color: Colors.green[100],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isContinued ? 8 : 24),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(4),
                  ),
                )
              : BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(
                    color: Colors.blue[100],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(isContinued ? 8 : 24),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(8),
                  ),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                softWrap: true,
                style: TextStyle(
                  height: 1.5,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _dateFormatter.format(message.timestamp),
                softWrap: true,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.blueGrey[200],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

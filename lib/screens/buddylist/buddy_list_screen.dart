import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chat/chatclient/client.dart';

class BuddyListScreen extends HookWidget {
  final BuddyListScreenArgs args;
  const BuddyListScreen({Key key, @required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text("Buddies"),
      ),
      body: Center(
        child: Text("buddies...."),
      ),
    );
  }
}

class BuddyListScreenArgs {
  final ChatClient chatClient;

  const BuddyListScreenArgs({
    @required this.chatClient,
  });
}

import 'package:flutter/material.dart';

import 'screens/chat/image_viewer_screen.dart';
import 'screens/new_chat/new_chat_screen.dart';
import 'screens/buddylist/buddy_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/profile/profile_screen.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == "/") {
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return LoginScreen();
        },
      );
    }
    if (settings.name == "/buddylist") {
      BuddyListScreenArgs args = settings.arguments;
      return MaterialPageRoute(builder: (BuildContext context) {
        return BuddyListScreen(args: args);
      });
    }
    if (settings.name == "/chat") {
      ChatScreenArgs args = settings.arguments;
      return MaterialPageRoute(builder: (BuildContext context) {
        return ChatScreen(args: args);
      });
    }
    if (settings.name == "/chat/image_viewer") {
      ImageViewerScreenArgs args = settings.arguments;
      return MaterialPageRoute(builder: (BuildContext context) {
        return ImageViewerScreen(args: args);
      });
    }
    if (settings.name == "/profile") {
      return MaterialPageRoute(builder: (BuildContext context) {
        return ProfileScreen();
      });
    }
    if (settings.name == "/newchat") {
      return MaterialPageRoute(builder: (BuildContext context) {
        NewChatScreenArgs args = settings.arguments;
        return NewChatScreen(args: args);
      });
    }
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return Container(
          child: Text("You shouldn't be here!\n${settings.name}"),
        );
      },
    );
  }
}

import 'package:chat/chatclient/client.dart';
import 'package:chat/models/connection_settings.dart';
import 'package:chat/models/user.dart';
import 'package:chat/screens/buddylist/buddy_list_screen.dart';
import 'package:chat/screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoginFormScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> shouldRemember = useState(true);
    ValueNotifier<ConnectionSettings> connectionSettings =
        useState(ConnectionSettings());
    ValueNotifier<User> user = useState(User());
    ValueNotifier<GlobalKey<FormState>> formKey =
        useState(GlobalKey<FormState>());
    ValueNotifier<bool> isComplete = useState(false);
    ValueNotifier<ChatClient> chatClient = useState(ChatClient());
    ValueNotifier<bool> isConnected = useState(false);

    handleChangeRememberMe(bool val) {
      shouldRemember.value = val;
    }

    useEffect(() {
      if (isComplete.value) {
        chatClient.value = ChatClient(
          host: connectionSettings.value.host,
          port: connectionSettings.value.port,
          userAtDomain: user.value.username,
          password: user.value.password,
          onMessageReceived: (String msg) {
            // messages.value = [...messages.value, msg];
            // print(messages.value.toList());
          },
        );
        try {
          chatClient.value.connect();
          isConnected.value = true;
        } catch (ex0) {
          print("Uh oh ${ex0.toString()}");
        }
      }
      return () {};
    }, [isComplete.value]);

    useEffect(() {
      isConnected.addListener(() async {
        if (isConnected.value) {
          print("~~~~ Connected ~~~~");
          await Future.delayed(Duration(seconds: 3));
          Navigator.of(context).pushReplacementNamed(
            "/buddylist",
            arguments: BuddyListScreenArgs(chatClient: chatClient.value),
          );
        }
      });
      return () {};
    }, const []);

    return Scaffold(
      body: isConnected.value
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey.value,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: "eg: 127.0.0.1",
                          labelText: "Server Host",
                        ),
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "Enter the server host name or IP";
                          }
                          return null;
                        },
                        onSaved: (String val) {
                          connectionSettings.value.host = val.trim();
                        },
                      ),
                      TextFormField(
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: "eg: 5222",
                          labelText: "Port",
                        ),
                        initialValue: "5222",
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: false,
                          signed: false,
                        ),
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "Enter the server port";
                          }
                          return null;
                        },
                        onSaved: (String val) {
                          connectionSettings.value.port = int.parse(val.trim());
                        },
                      ),
                      TextFormField(
                        autocorrect: false,
                        decoration: InputDecoration(labelText: "Username"),
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "Enter your username";
                          }
                          return null;
                        },
                        onSaved: (String val) {
                          user.value.username = val.trim();
                        },
                      ),
                      TextFormField(
                        autocorrect: false,
                        obscureText: true,
                        decoration: InputDecoration(labelText: "Password"),
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "Enter your password";
                          }
                          return null;
                        },
                        onSaved: (String val) {
                          user.value.password = val.trim();
                        },
                      ),
                      CheckboxListTile(
                        value: shouldRemember.value,
                        title: Text("Remember me"),
                        onChanged: handleChangeRememberMe,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RaisedButton(
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 20),
                              onPressed: () {
                                if (formKey.value.currentState.validate()) {
                                  formKey.value.currentState.save();
                                  isComplete.value = true;
                                }
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

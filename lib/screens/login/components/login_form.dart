import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../../models/connection_settings.dart';
import '../../../models/user.dart';
import '../../../chatclient/chat_provider.dart';
import '../../buddylist/buddy_list_screen.dart';

class LoginForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> shouldRemember = useState(true);
    ValueNotifier<ConnectionSettings> connectionSettings =
        useState(ConnectionSettings());
    ValueNotifier<User> user = useState(User());
    ValueNotifier<GlobalKey<FormState>> formKey =
        useState(GlobalKey<FormState>());
    ValueNotifier<bool> isBusy = useState(false);
    ValueNotifier<bool> hasLoadedSettings = useState(false);
    loadSettings() async {
      isBusy.value = true;
      UserProvider userProvider = new UserProvider();
      ConnectionSettingsProvider connectionSettingsProvider =
          new ConnectionSettingsProvider();
      List<Future> futures = [
        userProvider.get(),
        connectionSettingsProvider.get(),
      ];
      List result = await Future.wait(futures);
      if (result[0] != null && result[1] != null) {
        user.value = result[0];
        connectionSettings.value = result[1];
        hasLoadedSettings.value = true;
        print("Loaded settings from DB");
      } else {
        print("Settings not found");
        isBusy.value = false;
      }
    }

    handleChangeRememberMe(bool val) {
      shouldRemember.value = val;
    }

    doLogin() async {
      isBusy.value = true;
      await Future.delayed(Duration(milliseconds: 500));
      bool isConnected =
          await Provider.of<ChatProvider>(context, listen: false).connect(
        connectionSettings.value,
        user.value,
      );
      if (isConnected) {
        await Future.delayed(Duration(seconds: 1));
        Navigator.of(context).pushReplacementNamed(
          "/buddylist",
          arguments: BuddyListScreenArgs(),
        );
      } else {
        isBusy.value = false;
        Scaffold.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Unable to login. Please retry"),
          ),
        );
      }
    }

    handleSubmit() async {
      if (!formKey.value.currentState.validate()) {
        return;
      }
      formKey.value.currentState.save();
      UserProvider userProvider = new UserProvider();
      ConnectionSettingsProvider connectionSettingsProvider =
          new ConnectionSettingsProvider();
      print(
          "About to save: ${user.value.toMap()} and\n${connectionSettings.value.toMap()}");
      List<Future> futures = [
        userProvider.save(user.value),
        connectionSettingsProvider.save(connectionSettings.value),
      ];
      await Future.wait(futures);
      doLogin();
    }

    useEffect(() {
      hasLoadedSettings.addListener(() {
        if (hasLoadedSettings.value) {
          doLogin();
        }
      });
      loadSettings();
      return () {};
    }, const []);

    if (isBusy.value) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey.value,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                autocorrect: false,
                initialValue: "192.168.29.177",
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
                initialValue: "5222",
                decoration: InputDecoration(
                  hintText: "eg: 5222",
                  labelText: "Port",
                ),
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
                initialValue: "user1@xmpp1.ddplabs.com",
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
                      onPressed: handleSubmit,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddBuddy extends HookWidget {
  final Function onAdd;
  const AddBuddy({
    Key key,
    this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String> username = useState("");
    ValueNotifier<GlobalKey<FormState>> formKey =
        useState(GlobalKey<FormState>());
    handleCancel() {
      Navigator.of(context).pop();
    }

    addBuddy() {
      if (!formKey.value.currentState.validate()) {
        return;
      }
      formKey.value.currentState.save();
      onAdd(username.value);
      Navigator.of(context).pop();
    }

    return AlertDialog(
      content: Form(
        key: formKey.value,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: "Username",
            hintText: "eg: user2@xmpp1.ddplabs.com",
          ),
          validator: (String val) {
            if (val.isEmpty) {
              return "Please enter your buddy's username";
            }
            return null;
          },
          onSaved: (String val) {
            username.value = val;
          },
        ),
      ),
      actions: [
        FlatButton(
          onPressed: handleCancel,
          child: Text("CANCEL"),
        ),
        FlatButton(
          onPressed: addBuddy,
          child: Text(
            "ADD",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

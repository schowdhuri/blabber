import 'package:flutter/material.dart';

import '../../../models/user.dart';
import 'profile_static_view.dart';

class ProfileForm extends StatelessWidget {
  final bool isEditMode;
  final User user;
  final Function onChangeName;
  final Function setEditMode;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ProfileForm({
    @required this.isEditMode,
    @required this.user,
    @required this.onChangeName,
    @required this.setEditMode,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) {
      return ProfileStaticView(
        user: user,
        setEditMode: setEditMode,
      );
    }
    return Container(
      padding: EdgeInsets.only(left: 40, right: 20),
      child: Form(
        key: formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                autocorrect: false,
                initialValue: user.friendlyName,
                decoration: InputDecoration(
                  hintText: "Display Name",
                ),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Please enter a display name";
                  }
                  return null;
                },
                onSaved: onChangeName,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.green,
                size: 20,
              ),
              onPressed: () {
                if (!formKey.currentState.validate()) {
                  return;
                }
                formKey.currentState.save();
                setEditMode(false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

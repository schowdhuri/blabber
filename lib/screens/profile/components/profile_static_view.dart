import 'package:flutter/material.dart';
import '../../../models/user.dart';

class ProfileStaticView extends StatelessWidget {
  final User user;
  final Function setEditMode;

  ProfileStaticView({
    Key key,
    @required this.user,
    this.setEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        setEditMode != null ? SizedBox(width: 40) : Container(),
        Text(
          user.friendlyName,
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 24,
          ),
        ),
        setEditMode != null
            ? IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.black38,
                  size: 20,
                ),
                onPressed: () {
                  setEditMode(true);
                },
              )
            : Container(),
      ],
    );
  }
}

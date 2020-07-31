import 'package:flutter/material.dart';
import '../../../models/user.dart';

class ProfileStaticView extends StatelessWidget {
  const ProfileStaticView({
    Key key,
    @required this.user,
    @required this.setEditMode,
  }) : super(key: key);

  final User user;
  final Function setEditMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          user.friendlyName,
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 24,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.edit,
            color: Colors.black38,
            size: 20,
          ),
          onPressed: () {
            setEditMode(true);
          },
        ),
      ],
    );
  }
}

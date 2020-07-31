import 'package:chat/models/user.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final ValueNotifier<User> user;
  final Function onChangeAvatar;

  const ProfileImage({
    Key key,
    @required this.user,
    @required this.onChangeAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
          child: Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 64,
              backgroundImage:
                  user.value != null && user.value.imageData != null
                      ? Image.memory(user.value.imageData).image
                      : null,
            ),
          ),
        ),
        Positioned(
          left: size.width / 2 + 8,
          bottom: 0,
          child: RaisedButton.icon(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            onPressed: onChangeAvatar,
            icon: Icon(
              Icons.edit,
              color: Colors.blueGrey,
              size: 20,
            ),
            label: Container(),
            shape: CircleBorder(),
          ),
        ),
      ],
    );
  }
}

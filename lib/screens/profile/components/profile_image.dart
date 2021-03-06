import 'package:flutter/material.dart';

import '../../../models/user.dart';

class ProfileImage extends StatelessWidget {
  final User user;
  final Function onChangeAvatar;

  const ProfileImage({
    Key key,
    @required this.user,
    this.onChangeAvatar,
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
              backgroundImage: user != null && user.imageData != null
                  ? Image.memory(user.imageData).image
                  : null,
            ),
          ),
        ),
        onChangeAvatar != null
            ? Positioned(
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
              )
            : Container(),
        onChangeAvatar != null
            ? Positioned(
                left: size.width / 2 - 90,
                bottom: 0,
                child: RaisedButton.icon(
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  onPressed: () => onChangeAvatar(shouldUseCamera: true),
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                  label: Container(),
                  shape: CircleBorder(),
                ),
              )
            : Container(),
      ],
    );
  }
}

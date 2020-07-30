import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image/image.dart' as Img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../chatclient/chat_provider.dart';

enum _Action {
  EditProfile,
  Preferences,
}

class ActionsMenu extends HookWidget {
  final _picker = ImagePicker();
  final Function onChangeAvatar;

  ActionsMenu({this.onChangeAvatar});

  @override
  Widget build(BuildContext context) {
    Future<File> getImage() async {
      final pickedFile = await _picker.getImage(
        source: ImageSource.gallery,
      );
      return File(pickedFile.path);
    }

    Future<File> cropImage(File file) async {
      return ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: "Crop your image",
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );
    }

    Future<String> resizeImage(File file) async {
      Img.Image image = Img.decodeImage(file.readAsBytesSync());
      // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
      return base64Encode(
        Img.encodeJpg(
          Img.copyResize(image, width: 32),
        ),
      );
    }

    Future<void> getMyVCard() async {
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      User user = await chatProvider.getProfile();
      onChangeAvatar(user.avatar);
    }

    Future<void> updateAvatar() async {
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);

      String imageData = await getImage().then(cropImage).then(resizeImage);
      chatProvider.updateAvatar(imageData);
    }

    handleSelect(_Action action) {
      switch (action) {
        case _Action.EditProfile:
          updateAvatar();
          break;

        case _Action.Preferences:
          getMyVCard();
          break;

        default:
      }
    }

    return PopupMenuButton(
      offset: Offset(0, 80),
      onSelected: handleSelect,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _Action.EditProfile,
          child: Text("Edit Profile"),
        ),
        PopupMenuItem(
          value: _Action.Preferences,
          child: Text("Preferences"),
        ),
      ],
    );
  }
}

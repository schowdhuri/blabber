import 'dart:io';
import 'dart:typed_data';
import 'package:chat/models/user.dart';
import 'package:chat/screens/profile/components/profile_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as Img;

import '../../chatclient/chat_provider.dart';
import 'components/profile_image.dart';

class ProfileScreen extends HookWidget {
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<User> user = useState(User());
    ValueNotifier<bool> isNameEditMode = useState(false);
    ValueNotifier<bool> hasProfileLoaded = useState(false);

    Future<File> pickImage({bool shouldUseCamera = false}) async {
      final pickedFile = await _picker.getImage(
        source: shouldUseCamera ? ImageSource.camera : ImageSource.gallery,
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

    Future<Uint8List> resizeImage(File file) async {
      Img.Image image = Img.decodeImage(file.readAsBytesSync());
      return Img.encodePng(
        Img.copyResize(image, width: 128),
      );
    }

    Future<void> getMyProfile() async {
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      user.value = await chatProvider.getMyProfile();
      hasProfileLoaded.value = true;
    }

    Future<void> handleChangeAvatar({bool shouldUseCamera = false}) async {
      Uint8List imageData = await pickImage(shouldUseCamera: shouldUseCamera)
          .then(cropImage)
          .then(resizeImage);
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      chatProvider.updateProfile(user.value, imageData: imageData);
      User _user = User(
        username: user.value.username,
        imageData: imageData,
        name: user.value.name,
      );
      user.value = _user;
    }

    void handleChangeName(String value) {
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      chatProvider.updateProfile(user.value, name: value);
      User _user = User(
        username: user.value.username,
        imageData: user.value.imageData,
        name: value,
      );
      user.value = _user;
    }

    useEffect(() {
      getMyProfile();
      return () {};
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: !hasProfileLoaded.value
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileImage(
                  user: user.value,
                  onChangeAvatar: handleChangeAvatar,
                ),
                SizedBox(height: 32),
                ProfileForm(
                  isEditMode: isNameEditMode.value,
                  user: user.value,
                  setEditMode: (bool val) {
                    isNameEditMode.value = val;
                  },
                  onChangeName: handleChangeName,
                ),
              ],
            ),
    );
  }
}

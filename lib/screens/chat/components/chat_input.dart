import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends HookWidget {
  final Function onSend;
  final Function onUpload;
  final _picker = ImagePicker();

  ChatInput({
    Key key,
    this.onSend,
    this.onUpload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<TextEditingController> txtController =
        useState(TextEditingController());

    Future<String> pickImage({bool shouldUseCamera = false}) async {
      final pickedFile = await _picker.getImage(
        source: shouldUseCamera ? ImageSource.camera : ImageSource.gallery,
      );
      return pickedFile?.path;
    }

    Future<void> handleUpload() async {
      String filePath = await pickImage();
      if (filePath == null) {
        return;
      }
      String contentType =
          filePath.endsWith(".jpg") || filePath.endsWith(".jpeg")
              ? "image/jpg"
              : filePath.endsWith(".png") ? "image/png" : null;
      if (contentType == null) {
        return;
      }
      int length = await File(filePath).length();
      onUpload(
        filePath: filePath,
        contentType: contentType,
        length: length,
      );
    }

    handleSend(String message) {
      message = message.trim();
      if (message.isEmpty) {
        return;
      }
      onSend(message);
      txtController.value.clear();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16, 4, 0, 4),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: txtController.value,
              onSubmitted: handleSend,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              handleUpload();
            },
            icon: Icon(
              Icons.image,
              size: 18,
              color: Colors.blueGrey,
            ),
          ),
          IconButton(
            onPressed: () {
              handleSend(txtController.value.text);
            },
            icon: Icon(
              Icons.send,
              size: 18,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}

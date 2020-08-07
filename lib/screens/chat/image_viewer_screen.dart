import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerScreen extends HookWidget {
  final ImageViewerScreenArgs args;

  ImageViewerScreen({Key key, this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(args.url),
        ),
      ),
    );
  }
}

class ImageViewerScreenArgs {
  final String url;
  ImageViewerScreenArgs(this.url);
}

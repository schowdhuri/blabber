import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String url;

  const ImagePreview({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image(
        image: NetworkImage(url),
        height: 128,
        width: 128,
      ),
    );
  }
}

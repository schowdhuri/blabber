import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadService {
  DownloadService._pvtConstructor();
  static final DownloadService _instance = DownloadService._pvtConstructor();
  factory DownloadService() => _instance;

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: true);
  }

  Future<String> startDownload(
    String url,
    String path, {
    bool showNotification = false,
    bool openFileFromNotification = false,
  }) async {
    // await getApplicationDocumentsDirectory();
    return FlutterDownloader.enqueue(
      url: path,
      savedDir: path,
      showNotification: showNotification,
      openFileFromNotification: openFileFromNotification,
    );
  }
}

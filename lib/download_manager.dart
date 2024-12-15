// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadManager {
  static Future<void> downloadFile(String url, String fileName) async {
    const directory = '/storage/emulated/0/Download';

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: directory,
      fileName: fileName,
      showNotification: true, // Show progress notification
      openFileFromNotification: true, // Open file after download
    );
  }

  static Future<void> downloadGameFile(
      BuildContext context, String url, String fileName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$fileName Downloading...')),
      );

      final nFileName =
          '${fileName.replaceFirst(".zip", "")}-${DateTime.now().millisecondsSinceEpoch}.zip';
      await downloadFile(url, nFileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download $fileName')),
      );
    }
  }
}

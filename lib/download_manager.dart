import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

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

  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<void> downloadGameFile(
      BuildContext context, String url, String fileName) async {
    try {
      bool permissionGranted = await requestStoragePermission();
      if (!permissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')));
        return;
      }

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

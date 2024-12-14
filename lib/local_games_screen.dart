import 'dart:async';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';

class LocalGame {
  final String name;
  final int progress;
  final String url;

  LocalGame({required this.url, required this.name, required this.progress});
}

class LocalGamesScreen extends StatefulWidget {
  const LocalGamesScreen({super.key});

  @override
  State<LocalGamesScreen> createState() => _LocalGamesScreenState();
}

class _LocalGamesScreenState extends State<LocalGamesScreen> {
  Timer? _timer;
  List<DownloadTask> _localGames = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _loadProgress();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _loadProgress() async {
    final games = await FlutterDownloader.loadTasks() ?? [];

    setState(() {
      _localGames = games;
    });
  }

  Future<void> onActionPressed(DownloadTaskStatus status, String taskId) async {
    switch (status) {
      case DownloadTaskStatus.paused:
        await FlutterDownloader.resume(taskId: taskId);
        break;
      case DownloadTaskStatus.running || DownloadTaskStatus.enqueued:
        await FlutterDownloader.pause(taskId: taskId);
        break;
      default:
        await FlutterDownloader.remove(taskId: taskId);
    }
  }

  Icon statusIcon(DownloadTaskStatus status) {
    switch (status) {
      case DownloadTaskStatus.paused:
        return const Icon(
          Icons.play_arrow,
          color: Colors.green,
        );
      case DownloadTaskStatus.running || DownloadTaskStatus.enqueued:
        return const Icon(
          Icons.pause,
          color: Colors.yellow,
        );
      default:
        return const Icon(
          Icons.delete,
          color: Colors.red,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _localGames.length,
      itemBuilder: (context, index) {
        final game = _localGames[index];

        return ListTile(
          title: Text(game.filename!.replaceFirst(".zip", "")),
          trailing: IconButton(
              onPressed: () async {
                await onActionPressed(game.status, game.taskId);
              },
              icon: statusIcon(game.status)),
          subtitle: game.status == DownloadTaskStatus.complete
              ? const Text("Downloaded")
              : game.status == DownloadTaskStatus.failed
                  ? const Text("Failed")
                  : game.status == DownloadTaskStatus.canceled
                      ? const Text("Canceled")
                      : Text('${game.progress.toString()}%'),
        );
      },
    ));
  }
}

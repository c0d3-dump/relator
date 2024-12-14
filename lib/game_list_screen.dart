import 'package:relator/download_manager.dart';
import 'package:relator/models/game_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class GameListScreen extends StatefulWidget {
  final String name;
  final String id;

  const GameListScreen({super.key, required this.name, required this.id});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  late Future<List<Game>> _gamesFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gamesFuture = loadGames(widget.id);
    _searchController.addListener(searchGames);
  }

  Future<List<Game>> loadGames(String platform) async {
    final jsonString =
        await rootBundle.loadString('assets/games/$platform.json');
    return parseGames(jsonString);
  }

  Future<void> searchGames() async {
    final data = await loadGames(widget.id);
    String query = _searchController.text.toLowerCase();

    setState(() {
      _gamesFuture = Future.value(data.where((d) {
        return d.name.toLowerCase().contains(query);
      }).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          backgroundColor: Colors.black87,
          surfaceTintColor: Colors.black87,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                    hintText: "Search games...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.black87),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Game>>(
                future: _gamesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No games found.'));
                  }

                  final games = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return ListTile(
                        title: Text(game.name.replaceFirst(".zip", "")),
                        subtitle: Text(game.size),
                        trailing: IconButton(
                            onPressed: () async {
                              DownloadManager.downloadGameFile(
                                  context, game.url, game.name);
                            },
                            icon: const Icon(
                              Icons.download,
                              color: Colors.green,
                            )),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ));
  }
}

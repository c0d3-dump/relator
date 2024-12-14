import 'package:relator/game_list_screen.dart';
import 'package:relator/models/platform_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PlatformListScreen extends StatefulWidget {
  const PlatformListScreen({super.key});

  @override
  State<PlatformListScreen> createState() => _PlatformListScreenState();
}

class _PlatformListScreenState extends State<PlatformListScreen> {
  late Future<List<Platform>> _platformsFuture;
  final TextEditingController _searchController = TextEditingController();

  final tileColors = [
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.deepPurple,
    Colors.cyan,
    Colors.brown,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    _platformsFuture = loadPlatforms();
    _searchController.addListener(searchPlatforms);
  }

  Future<List<Platform>> loadPlatforms() async {
    final jsonString = await rootBundle.loadString('assets/platform-list.json');
    return parsePlatforms(jsonString);
  }

  Future<void> searchPlatforms() async {
    final data = await loadPlatforms();
    String query = _searchController.text.toLowerCase();

    setState(() {
      _platformsFuture = Future.value(data.where((d) {
        return d.name.toLowerCase().contains(query);
      }).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
                hintText: "Search platforms...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.black87),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Platform>>(
            future: _platformsFuture,
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

              final platforms = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: platforms.length,
                itemBuilder: (context, index) {
                  final platform = platforms[index];
                  final randi = index % tileColors.length;

                  return ListTile(
                    tileColor: tileColors[randi],
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            platform.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text('${platform.length.toString()} games'),
                        Text(platform.size),
                      ],
                    ),
                    enableFeedback: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameListScreen(
                            name: platforms[index].name,
                            id: platforms[index].id),
                      ),
                    ),
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

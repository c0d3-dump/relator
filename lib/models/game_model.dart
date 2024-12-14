import 'dart:convert';

class Game {
  final String name;
  final String url;
  final String size;

  Game({required this.name, required this.url, required this.size});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['name'],
      url: json['url'],
      size: json['size'],
    );
  }
}

List<Game> parseGames(String jsonData) {
  final List<dynamic> jsonList = json.decode(jsonData);
  return jsonList.map((json) => Game.fromJson(json)).toList();
}

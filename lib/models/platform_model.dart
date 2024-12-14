import 'dart:convert';

class Platform {
  final String id;
  final String name;
  final String size;
  final int length;

  Platform(
      {required this.id,
      required this.name,
      required this.size,
      required this.length});

  factory Platform.fromJson(Map<String, dynamic> json) {
    return Platform(
      id: json['id'],
      name: json['name'],
      size: json['size'],
      length: json['length'],
    );
  }
}

List<Platform> parsePlatforms(String jsonData) {
  final List<dynamic> jsonList = json.decode(jsonData);
  return jsonList.map((json) => Platform.fromJson(json)).toList();
}

import 'package:equatable/equatable.dart';

class ArtistModel extends Equatable {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final String? genre;
  final int songCount;
  final DateTime createdAt;

  const ArtistModel({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.genre,
    this.songCount = 0,
    required this.createdAt,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return ArtistModel(
      id: json['\$id'] ?? json['id'] ?? data['\$id'] ?? data['id'] ?? '',
      name: data['name'] ?? json['name'] ?? '',
      bio: data['bio'] ?? json['bio'],
      imageUrl: data['imageUrl'] ?? json['imageUrl'],
      genre: data['genre'] ?? json['genre'],
      songCount: data['songCount'] ?? json['songCount'] ?? 0,
      createdAt: DateTime.parse(
        data['createdAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
      'genre': genre,
      'songCount': songCount,
    };
  }

  @override
  List<Object?> get props => [id, name, bio, imageUrl, genre, songCount];
}

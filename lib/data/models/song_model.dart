import 'package:equatable/equatable.dart';

class SongModel extends Equatable {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? album;
  final String genre;
  final String audioUrl;
  final String? videoUrl;
  final String? imageUrl;
  final String? lyrics;
  final int durationSeconds;
  final bool isPremium;
  final bool isVideo;
  final int playCount;
  final DateTime createdAt;

  const SongModel({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.album,
    required this.genre,
    required this.audioUrl,
    this.videoUrl,
    this.imageUrl,
    this.lyrics,
    required this.durationSeconds,
    this.isPremium = false,
    this.isVideo = false,
    this.playCount = 0,
    required this.createdAt,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return SongModel(
      id: json['\$id'] ?? json['id'] ?? data['\$id'] ?? data['id'] ?? '',
      title: data['title'] ?? json['title'] ?? '',
      artistId: data['artistId'] ?? json['artistId'] ?? '',
      artistName: data['artistName'] ?? json['artistName'] ?? '',
      album: data['album'] ?? json['album'],
      genre: data['genre'] ?? json['genre'] ?? '',
      audioUrl: data['audioUrl'] ?? json['audioUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? json['videoUrl'],
      imageUrl: data['imageUrl'] ?? json['imageUrl'],
      lyrics: data['lyrics'] ?? json['lyrics'],
      durationSeconds: data['durationSeconds'] ?? json['durationSeconds'] ?? 0,
      isPremium: data['isPremium'] ?? json['isPremium'] ?? false,
      isVideo: data['isVideo'] ?? json['isVideo'] ?? false,
      playCount: data['playCount'] ?? json['playCount'] ?? 0,
      createdAt: DateTime.parse(
        data['createdAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artistId': artistId,
      'artistName': artistName,
      'album': album,
      'genre': genre,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'lyrics': lyrics,
      'durationSeconds': durationSeconds,
      'isPremium': isPremium,
      'isVideo': isVideo,
      'playCount': playCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artistId,
    String? artistName,
    String? album,
    String? genre,
    String? audioUrl,
    String? videoUrl,
    String? imageUrl,
    String? lyrics,
    int? durationSeconds,
    bool? isPremium,
    bool? isVideo,
    int? playCount,
    DateTime? createdAt,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      lyrics: lyrics ?? this.lyrics,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isPremium: isPremium ?? this.isPremium,
      isVideo: isVideo ?? this.isVideo,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id, title, artistId, artistName, album, genre,
    audioUrl, videoUrl, imageUrl, durationSeconds,
    isPremium, isVideo, playCount,
  ];
}

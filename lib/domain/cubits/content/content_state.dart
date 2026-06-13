import 'package:equatable/equatable.dart';
import '../../../data/models/song_model.dart';
import '../../../data/models/artist_model.dart';

enum ContentStatus { initial, loading, loaded, error }

class ContentState extends Equatable {
  final ContentStatus status;
  final List<SongModel> songs;
  final List<ArtistModel> artists;
  final List<SongModel> offlineSongs;
  final String? selectedGenre;
  final String? errorMessage;

  const ContentState({
    this.status = ContentStatus.initial,
    this.songs = const [],
    this.artists = const [],
    this.offlineSongs = const [],
    this.selectedGenre,
    this.errorMessage,
  });

  ContentState copyWith({
    ContentStatus? status,
    List<SongModel>? songs,
    List<ArtistModel>? artists,
    List<SongModel>? offlineSongs,
    String? selectedGenre,
    String? errorMessage,
  }) {
    return ContentState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      artists: artists ?? this.artists,
      offlineSongs: offlineSongs ?? this.offlineSongs,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, songs, artists, offlineSongs, selectedGenre, errorMessage];
}

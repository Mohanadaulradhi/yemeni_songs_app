import 'package:equatable/equatable.dart';
import '../../../data/models/song_model.dart';

enum PlayerStatus { stopped, playing, paused, loading, error }

class PlayerState extends Equatable {
  final PlayerStatus status;
  final SongModel? currentSong;
  final Duration position;
  final Duration duration;
  final List<SongModel> queue;
  final int currentIndex;
  final bool isOffline;
  final String? errorMessage;

  const PlayerState({
    this.status = PlayerStatus.stopped,
    this.currentSong,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.queue = const [],
    this.currentIndex = 0,
    this.isOffline = false,
    this.errorMessage,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    SongModel? currentSong,
    Duration? position,
    Duration? duration,
    List<SongModel>? queue,
    int? currentIndex,
    bool? isOffline,
    String? errorMessage,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentSong: currentSong ?? this.currentSong,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentSong, position, duration, queue, currentIndex, isOffline, errorMessage];
}

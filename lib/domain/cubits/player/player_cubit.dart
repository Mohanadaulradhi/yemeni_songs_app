import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'player_state.dart';
import '../../../data/models/song_model.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _positionSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;

  PlayerCubit() : super(const PlayerState()) {
    _setupListeners();
  }

  void _setupListeners() {
    _positionSub = _audioPlayer.positionStream.listen((pos) {
      if (state.status != PlayerStatus.stopped) {
        emit(state.copyWith(position: pos));
      }
    });

    _durationSub = _audioPlayer.durationStream.listen((dur) {
      emit(state.copyWith(duration: dur ?? Duration.zero));
    });

    _playerStateSub = _audioPlayer.playerStateStream.listen((playerState) {
      switch (playerState.processingState) {
        case ProcessingState.idle:
          emit(state.copyWith(status: PlayerStatus.stopped));
          break;
        case ProcessingState.loading:
          emit(state.copyWith(status: PlayerStatus.loading));
          break;
        case ProcessingState.buffering:
          emit(state.copyWith(status: PlayerStatus.loading));
          break;
        case ProcessingState.ready:
          if (state.status != PlayerStatus.paused) {
            emit(state.copyWith(status: PlayerStatus.playing));
          }
          break;
        case ProcessingState.completed:
          _next();
          break;
      }
    });
  }

  Future<void> playSong(SongModel song, {bool isOffline = false, String? localPath}) async {
    emit(state.copyWith(
      status: PlayerStatus.loading,
      currentSong: song,
      isOffline: isOffline,
    ));

    try {
      final source = isOffline && localPath != null
          ? AudioSource.file(localPath)
          : AudioSource.uri(Uri.parse(song.audioUrl));

      await _audioPlayer.setAudioSource(source);
      await _audioPlayer.play();
      emit(state.copyWith(status: PlayerStatus.playing));
    } catch (e) {
      emit(state.copyWith(
        status: PlayerStatus.error,
        errorMessage: 'تعذر تشغيل الأغنية. تأكد من وجود الملف أو اتصالك بالإنترنت.',
      ));
    }
  }

  Future<void> playFromQueue(List<SongModel> songs, {int startIndex = 0}) async {
    emit(state.copyWith(
      queue: songs,
      currentIndex: startIndex,
    ));

    if (songs.isNotEmpty) {
      await playSong(songs[startIndex]);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.status == PlayerStatus.playing) {
      await _audioPlayer.pause();
      emit(state.copyWith(status: PlayerStatus.paused));
    } else if (state.status == PlayerStatus.paused) {
      await _audioPlayer.play();
      emit(state.copyWith(status: PlayerStatus.playing));
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    emit(state.copyWith(position: position));
  }

  Future<void> _next() async {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex < state.queue.length) {
      emit(state.copyWith(currentIndex: nextIndex));
      await playSong(state.queue[nextIndex]);
    } else {
      await stop();
    }
  }

  Future<void> next() async {
    await _audioPlayer.stop();
    await _next();
  }

  Future<void> previous() async {
    final prevIndex = state.currentIndex - 1;
    if (prevIndex >= 0) {
      emit(state.copyWith(currentIndex: prevIndex));
      await _audioPlayer.stop();
      await playSong(state.queue[prevIndex]);
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    emit(const PlayerState());
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}

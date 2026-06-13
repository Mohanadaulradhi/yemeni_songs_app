import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'content_state.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/models/song_model.dart';

class ContentCubit extends Cubit<ContentState> {
  final ContentRepository _contentRepository;

  ContentCubit(this._contentRepository) : super(const ContentState());

  Future<void> loadSongs({String? genre}) async {
    emit(state.copyWith(status: ContentStatus.loading, selectedGenre: genre));

    try {
      final songs = await _contentRepository.getSongs(genre: genre);
      emit(state.copyWith(
        status: ContentStatus.loaded,
        songs: songs,
      ));
    } catch (e) {
      final msg = _friendlyError(e, fallback: 'فشل تحميل الأغاني');
      emit(state.copyWith(
        status: ContentStatus.error,
        errorMessage: msg,
      ));
    }
  }

  Future<void> loadArtists() async {
    try {
      final artists = await _contentRepository.getArtists();
      emit(state.copyWith(artists: artists));
    } catch (_) {}
  }

  Future<void> loadOfflineSongs() async {
    try {
      final songs = _contentRepository.getOfflineSongs();
      emit(state.copyWith(offlineSongs: songs));
    } catch (_) {}
  }

  Future<void> downloadSong({
    required String url,
    required String songId,
    String? fileName,
  }) async {
    try {
      final localPath = await _contentRepository.downloadSong(
        url: url,
        songId: songId,
        fileName: fileName,
      );
      await _contentRepository.saveOfflineSongMetadata(songId, localPath);
      await loadOfflineSongs();
    } catch (e) {
      final msg = _friendlyError(e, fallback: 'فشل تحميل الأغنية');
      emit(state.copyWith(
        status: ContentStatus.error,
        errorMessage: msg,
      ));
    }
  }

  String _friendlyError(Object e, {String fallback = 'حدث خطأ'}) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'الاتصال بطيء. تحقق من اتصالك بالإنترنت.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'لا يوجد اتصال بالإنترنت.';
      }
      switch (code) {
        case 401:
          return 'انتهت صلاحية الجلسة. سجل الدخول مرة أخرى.';
        case 404:
          return 'المورد المطلوب غير موجود على الخادم.';
        case 500:
          return 'خطأ في الخادم. حاول لاحقاً.';
      }
    }
    return fallback;
  }

  Future<void> removeDownload(String songId) async {
    await _contentRepository.removeOfflineSong(songId);
    await loadOfflineSongs();
  }

  Future<bool> isDownloaded(String songId) async {
    return await _contentRepository.isSongDownloaded(songId);
  }

  void filterByGenre(String genre) {
    loadSongs(genre: genre);
  }

  Future<SongModel?> getSongDetail(String songId) async {
    try {
      return await _contentRepository.getSongDetail(songId);
    } catch (_) {
      return null;
    }
  }

  String? getLocalPath(String songId) {
    return _contentRepository.getLocalSongPath(songId);
  }
}

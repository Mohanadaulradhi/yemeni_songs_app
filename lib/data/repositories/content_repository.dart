import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/remote/appwrite_provider.dart';
import '../providers/local/hive_provider.dart';
import '../models/song_model.dart';
import '../models/artist_model.dart';
import '../../core/constants/appwrite_constants.dart';
import '../../core/utils/connectivity_service.dart';

class ContentRepository {
  final AppwriteProvider _appwrite;
  final ConnectivityService _connectivity;
  final Dio _dio;

  ContentRepository(this._appwrite, this._connectivity)
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 15000),
          receiveTimeout: const Duration(milliseconds: 30000),
        ));

  Future<List<SongModel>> getSongs({String? genre, String? artistId}) async {
    final isOnline = await _connectivity.isConnected();

    if (isOnline) {
      try {
        final queries = <String>[];
        if (genre != null) queries.add('genre.equal("$genre")');
        if (artistId != null) queries.add('artistId.equal("$artistId")');

        final result = await _appwrite.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.songsCollection,
          queries: queries.isNotEmpty ? queries : null,
        );

        final docs = (result['documents'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        final songs = docs.map((doc) => SongModel.fromJson(doc)).toList();

        await _cacheSongs(songs);
        return songs;
      } catch (e) {
        return _getCachedSongs();
      }
    }

    return _getCachedSongs();
  }

  Future<List<SongModel>> _getCachedSongs() async {
    final cached = HiveProvider.getAllOfflineSongs();
    return cached.map((e) => SongModel.fromJson(e)).toList();
  }

  Future<void> _cacheSongs(List<SongModel> songs) async {
    for (final song in songs) {
      try {
        if (HiveProvider.getOfflineSong(song.id) == null) {
          await HiveProvider.saveOfflineSong(song.id, song.toJson());
        }
      } catch (_) {}
    }
  }

  Future<List<ArtistModel>> getArtists() async {
    final isOnline = await _connectivity.isConnected();

    if (isOnline) {
      try {
        final result = await _appwrite.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.artistsCollection,
        );

        final docs = (result['documents'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        return docs.map((doc) => ArtistModel.fromJson(doc)).toList();
      } catch (_) {
        return [];
      }
    }

    return [];
  }

  Future<SongModel> getSongDetail(String songId) async {
    final isOnline = await _connectivity.isConnected();

    if (isOnline) {
      try {
        final doc = await _appwrite.getDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.songsCollection,
          documentId: songId,
        );
        return SongModel.fromJson(doc);
      } catch (_) {}
    }

    final cached = HiveProvider.getOfflineSong(songId);
    if (cached != null) return SongModel.fromJson(cached);

    throw Exception('الأغنية غير موجودة');
  }

  Future<String> downloadSong({
    required String url,
    required String songId,
    String? fileName,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final songsDir = Directory('${dir.path}/offline_songs');
    if (!await songsDir.exists()) {
      await songsDir.create(recursive: true);
    }

    final filePath = '${songsDir.path}/${fileName ?? songId}.mp3';

    await _dio.download(url, filePath);

    return filePath;
  }

  Future<void> saveOfflineSongMetadata(String songId, String localPath) async {
    final existing = HiveProvider.getOfflineSong(songId) ?? {};
    existing['localPath'] = localPath;
    await HiveProvider.saveOfflineSong(songId, existing);
  }

  String? getLocalSongPath(String songId) {
    final data = HiveProvider.getOfflineSong(songId);
    return data?['localPath'] as String?;
  }

  Future<void> removeOfflineSong(String songId) async {
    final data = HiveProvider.getOfflineSong(songId);
    if (data != null) {
      final localPath = data['localPath'] as String?;
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    await HiveProvider.removeOfflineSong(songId);
  }

  List<SongModel> getOfflineSongs() {
    final songs = HiveProvider.getAllOfflineSongs()
        .where((e) => e['localPath'] != null)
        .toList();
    return songs.map((e) => SongModel.fromJson(e)).toList();
  }

  Future<bool> isSongDownloaded(String songId) async {
    final data = HiveProvider.getOfflineSong(songId);
    if (data == null) return false;
    final localPath = data['localPath'] as String?;
    if (localPath == null) return false;
    return await File(localPath).exists();
  }
}

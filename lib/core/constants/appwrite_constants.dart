import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConstants {
  AppwriteConstants._();

  static String get endpoint =>
      dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';

  static String get projectId =>
      dotenv.env['APPWRITE_PROJECT_ID'] ?? '';

  static String get databaseId =>
      dotenv.env['APPWRITE_DATABASE_ID'] ?? 'default';

  static const String usersCollection = 'users';
  static const String songsCollection = 'songs';
  static const String artistsCollection = 'artists';
  static const String genresCollection = 'genres';
  static const String subscriptionsCollection = 'subscriptions';
  static const String paymentsCollection = 'payments';
  static const String lyricsCollection = 'lyrics';

  static const String songsBucketId = 'media';
  static const String imagesBucketId = 'media';
  static const String lyricsBucketId = 'media';
}

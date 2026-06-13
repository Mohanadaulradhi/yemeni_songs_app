class AppConstants {
  AppConstants._();

  static const String appName = 'أغاني يمنية';
  static const String appVersion = '1.0.0';
  static const String defaultLocale = 'ar';

  static const int offlineCacheLimit = 100;
  static const int maxDownloadRetries = 3;
  static const Duration subscriptionCheckInterval = Duration(hours: 24);

  static const List<String> genres = [
    'صنعاني',
    'عدني',
    'حضرمي',
    'لحجي',
    'تعزي',
    'يافع',
    'شعبي',
    'تراثي',
  ];
}

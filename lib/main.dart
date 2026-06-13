import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/utils/connectivity_service.dart';
import 'data/providers/local/hive_provider.dart';
import 'data/providers/remote/appwrite_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env غير موجود — سنستخدم القيم الافتراضية في AppwriteConstants
  }

  try {
    await HiveProvider.init();
  } catch (e) {
    runApp(_ErrorApp(message: 'فشل تهيئة التخزين المحلي: $e'));
    return;
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final appwrite = AppwriteProvider();
  final connectivityService = ConnectivityService();

  runApp(YemeniSongsApp(
    appwrite: appwrite,
    connectivityService: connectivityService,
  ));
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/connectivity_service.dart';
import 'data/providers/remote/appwrite_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/content_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'domain/cubits/auth/auth_cubit.dart';
import 'domain/cubits/content/content_cubit.dart';
import 'domain/cubits/player/player_cubit.dart';
import 'domain/cubits/subscription/subscription_cubit.dart';
import 'domain/cubits/connectivity/connectivity_cubit.dart';

class YemeniSongsApp extends StatelessWidget {
  final AppwriteProvider appwrite;
  final ConnectivityService connectivityService;

  const YemeniSongsApp({
    super.key,
    required this.appwrite,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(appwrite);
    final contentRepository = ContentRepository(appwrite, connectivityService);
    final paymentService = KuraimiPaymentService();
    final paymentRepository = PaymentRepository(paymentService);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authRepository)),
        BlocProvider(create: (_) => ContentCubit(contentRepository)),
        BlocProvider(create: (_) => PlayerCubit()),
        BlocProvider(create: (_) => SubscriptionCubit(paymentRepository, authRepository)),
        BlocProvider(create: (_) => ConnectivityCubit(connectivityService)),
      ],
      child: MaterialApp.router(
        title: 'أغاني يمنية',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar', 'YE'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      ),
    );
  }
}

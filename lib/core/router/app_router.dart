import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/song_detail/song_detail_screen.dart';
import '../../presentation/screens/subscription/plans_screen.dart';
import '../../presentation/screens/subscription/payment_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/song/:id',
        builder: (_, state) => SongDetailScreen(
          songId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(path: '/plans', builder: (_, __) => const PlansScreen()),
      GoRoute(
        path: '/payment/:planId',
        builder: (_, state) => PaymentScreen(
          planId: state.pathParameters['planId']!,
        ),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
}

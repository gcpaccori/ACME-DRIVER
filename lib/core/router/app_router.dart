import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/signup_screen_steps.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/orders/presentation/screens/available_orders_screen.dart';
import '../../features/orders/presentation/screens/active_order_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// Route name constants
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signUp = '/signup';
  static const signUpSteps = '/signup-steps';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const availableOrders = '/orders';
  static const activeOrder = '/orders/active';
  static const history = '/history';
  static const earnings = '/earnings';
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(currentDriverProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoading = authAsync.isLoading;
      final isAuth = authAsync.value != null;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isLoginRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signUp ||
          state.matchedLocation == AppRoutes.signUpSteps ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (isLoading) return null; // stay on splash
      // Las cuentas de repartidor las crea ACME desde el panel; no hay registro en la app.
      if (state.matchedLocation == AppRoutes.signUp ||
          state.matchedLocation == AppRoutes.signUpSteps) {
        return isAuth ? AppRoutes.home : AppRoutes.login;
      }
      if (isSplash && !isLoading) {
        return isAuth ? AppRoutes.home : AppRoutes.login;
      }
      if (!isAuth && !isLoginRoute) return AppRoutes.login;
      if (isAuth && isLoginRoute) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUpSteps,
        builder: (_, __) => const SignUpScreenSteps(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.availableOrders,
            builder: (_, __) => const AvailableOrdersScreen(),
          ),
          GoRoute(
            path: AppRoutes.activeOrder,
            builder: (_, __) => const ActiveOrderScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.earnings,
            builder: (_, __) => const EarningsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: ${state.uri}'),
      ),
    ),
  );
});

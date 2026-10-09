import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/blocs/register/register_cubit.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_step1_screen.dart';
import '../../presentation/screens/auth/register_step2_screen.dart';
import '../../presentation/screens/auth/register_step3_screen.dart';
import '../../presentation/screens/auth/recovery_step1_screen.dart';
import '../../presentation/screens/auth/recovery_step3_screen.dart';
import '../../presentation/screens/main/main_layout_screen.dart';
import '../../presentation/screens/electricity/input_electricity_screen.dart';
import '../di/di.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import 'go_router_refresh_stream.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(getIt<AuthBloc>().stream),
  redirect: (context, state) {
    final authState = getIt<AuthBloc>().state;
    final isAuthRoute = state.matchedLocation == '/login' || 
                        state.matchedLocation.startsWith('/register') ||
                        state.matchedLocation.startsWith('/recovery');
    final isOnboardingRoute = state.matchedLocation == '/onboarding';

    if (authState is AuthInitial) {
      // Đang chờ check trạng thái (Splash)
      return null;
    }

    if (authState is AuthFirstTime) {
      if (!isOnboardingRoute) return '/onboarding';
      return null;
    }

    if (authState is AuthUnauthenticated) {
      if (!isAuthRoute) return '/login';
      return null;
    }

    if (authState is AuthAuthenticated) {
      if (isAuthRoute || isOnboardingRoute) return '/'; // Home
      return null;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainLayoutScreen(),
    ),
    GoRoute(
      path: '/input-electricity',
      builder: (context, state) => const InputElectricityScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterStep1Screen(),
      routes: [
        GoRoute(
          path: 'otp',
          builder: (context, state) {
            final cubit = state.extra as RegisterCubit;
            return BlocProvider.value(
              value: cubit,
              child: const RegisterStep2Screen(),
            );
          },
        ),
        GoRoute(
          path: 'success',
          builder: (context, state) {
            final cubit = state.extra as RegisterCubit;
            return BlocProvider.value(
              value: cubit,
              child: const RegisterStep3Screen(),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/recovery',
      builder: (context, state) => const RecoveryStep1Screen(),
      routes: [
        GoRoute(
          path: 'step1',
          builder: (context, state) => const RecoveryStep1Screen(),
        ),
        GoRoute(
          path: 'step3',
          builder: (context, state) => const RecoveryStep3Screen(),
        ),
      ],
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Spei Community - Home')),
      ),
    ),
  ],
);

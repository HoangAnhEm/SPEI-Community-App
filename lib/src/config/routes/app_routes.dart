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
import '../../presentation/screens/auth/recovery_step2_screen.dart';
import '../../presentation/screens/auth/recovery_step3_screen.dart';
import '../../presentation/screens/auth/recovery_success_screen.dart';
import '../../presentation/blocs/recovery/recovery_cubit.dart';
import '../../presentation/screens/main/main_layout_screen.dart';
import '../../presentation/screens/electricity/input_electricity_screen.dart';
import '../../presentation/screens/electricity/electricity_result_screen.dart';
import '../../presentation/screens/reward/reward_screen.dart';
import '../../presentation/screens/reward/reward_store_screen.dart';
import '../../presentation/screens/reward/reward_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/my_qr_screen.dart';
import '../../presentation/screens/profile/change_password_screen.dart';
import '../../presentation/screens/profile/change_password_success_screen.dart';
import '../../presentation/blocs/change_password/change_password_cubit.dart';
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
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'qr',
          builder: (context, state) => const MyQrScreen(),
        ),
        GoRoute(
          path: 'change-password',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<ChangePasswordCubit>(),
            child: const ChangePasswordScreen(),
          ),
          routes: [
            GoRoute(
              path: 'success',
              builder: (context, state) => const ChangePasswordSuccessScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/input-electricity',
      builder: (context, state) => const InputElectricityScreen(),
    ),
    GoRoute(
      path: '/electricity-result',
      builder: (context, state) => const ElectricityResultScreen(),
    ),
    GoRoute(
      path: '/reward',
      builder: (context, state) => const RewardScreen(),
    ),
    GoRoute(
      path: '/reward-store',
      builder: (context, state) => const RewardStoreScreen(),
    ),
    GoRoute(
      path: '/reward-detail',
      builder: (context, state) => const RewardDetailScreen(),
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
          path: 'step2',
          builder: (context, state) {
            final cubit = state.extra as RecoveryCubit;
            return BlocProvider.value(
              value: cubit,
              child: const RecoveryStep2Screen(),
            );
          },
        ),
        GoRoute(
          path: 'step3',
          builder: (context, state) {
            final cubit = state.extra as RecoveryCubit;
            return BlocProvider.value(
              value: cubit,
              child: const RecoveryStep3Screen(),
            );
          },
        ),
        GoRoute(
          path: 'success',
          builder: (context, state) {
            final cubit = state.extra as RecoveryCubit?;
            if (cubit != null) {
              return BlocProvider.value(
                value: cubit,
                child: const RecoverySuccessScreen(),
              );
            }
            return const RecoverySuccessScreen();
          },
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

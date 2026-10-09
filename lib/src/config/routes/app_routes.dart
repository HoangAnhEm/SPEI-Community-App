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

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
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

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
import '../../presentation/screens/emission/family_emission_history_screen.dart';
import '../../presentation/screens/emission/select_emission_type_screen.dart';
import '../../presentation/screens/emission/input_electricity_emission_screen.dart';
import '../../presentation/screens/emission/input_transportation_emission_screen.dart';
import '../../presentation/screens/emission/input_gas_emission_screen.dart';
import '../../presentation/screens/emission/input_refrigerant_emission_screen.dart';
import '../../presentation/screens/emission/input_waste_emission_screen.dart';
import '../../presentation/screens/emission/select_waste_type_screen.dart';
import '../../presentation/screens/emission/emission_preview_screen.dart';
import '../../domain/entities/emission_details.dart';
import '../../presentation/screens/emission/emission_record_detail_screen.dart';
import '../../presentation/screens/emission/emission_record_edit_screen.dart';
import '../../presentation/screens/emission/quick_calc/quick_calc_electricity_screen.dart';
import '../../presentation/screens/emission/quick_calc/quick_calc_transportation_screen.dart';
import '../../presentation/screens/emission/quick_calc/quick_calc_refrigerant_screen.dart';
import '../../presentation/screens/emission/quick_calc/quick_calc_waste_screen.dart';
import '../../presentation/screens/emission/quick_calc/quick_calc_gas_screen.dart';
import '../../domain/entities/household_emission.dart';
import '../../presentation/screens/reward/reward_screen.dart';
import '../../domain/entities/incident.dart';
import '../../presentation/screens/incident/incident_list_screen.dart';
import '../../presentation/screens/incident/incident_detail_screen.dart';
import '../../presentation/screens/incident/create_incident_screen.dart';
import '../../presentation/screens/reward/reward_store_screen.dart';
import '../../presentation/screens/reward/reward_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/my_qr_screen.dart';
import '../../presentation/screens/profile/change_password_screen.dart';
import '../../presentation/screens/profile/change_password_success_screen.dart';
import '../../presentation/blocs/change_password/change_password_cubit.dart';
import '../../presentation/blocs/create_household/create_household_cubit.dart';
import '../../presentation/screens/family/create_household_screen.dart';
import '../../presentation/screens/family/scan_household_qr_screen.dart';
import '../../presentation/screens/family/household_lookup_result_screen.dart';
import '../../presentation/blocs/household_lookup/household_lookup_cubit.dart';
import '../../presentation/screens/family/sent_invitations_screen.dart';
import '../../presentation/screens/family/household_join_requests_screen.dart';
import '../../presentation/screens/family/invite_user_screen.dart';
import '../../presentation/screens/family/household_qr_screen.dart';
import '../../presentation/screens/family/received_invitations_screen.dart';
import '../../presentation/screens/family/received_invitation_detail_screen.dart';
import '../../presentation/screens/family/my_join_requests_screen.dart';
import '../../presentation/blocs/sent_invitations/sent_invitations_cubit.dart';
import '../../presentation/blocs/household_join_requests/household_join_requests_cubit.dart';
import '../../presentation/blocs/invite_user/invite_user_cubit.dart';
import '../../presentation/blocs/received_invitations/received_invitations_cubit.dart';
import '../../presentation/blocs/my_join_requests/my_join_requests_cubit.dart';
import '../../domain/entities/household_invitation.dart';
import '../../presentation/screens/family/owner_permissions_screen.dart';
import '../../presentation/screens/family/transfer_ownership_screen.dart';
import '../../presentation/screens/family/remove_members_screen.dart';
import '../../presentation/screens/common/custom_success_screen.dart';
import '../../domain/entities/household.dart';
import '../../core/constants/app_colors.dart';
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
      path: '/family/create',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<CreateHouseholdCubit>(),
        child: const CreateHouseholdScreen(),
      ),
      routes: [
        GoRoute(
          path: 'success',
          builder: (context, state) {
            final household = state.extra as Household?;
            return CustomSuccessScreen(
              appBarTitle: 'SPEI Community',
              appBarSubtitle: 'GIEO MẦM SỐNG XANH',
              title: 'Mầm xanh đã sẵn sàng!',
              subtitle: 'Hộ gia đình của bạn đã được tạo. Cả nhà có thể bắt đầu hành trình cùng SPEI Community.',
              cardTag: 'Chủ hộ gia đình',
              cardHighlightText: household?.name ?? 'Nhà Mầm xanh',
              cardDescription: 'Đã tạo thành công hộ gia đình trên hệ thống.',
              infoCard: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8ECE5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin hộ gia đình',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tên hộ:', style: TextStyle(fontSize: 13, color: AppColors.subText)),
                        Text(
                          household?.name ?? 'Nhà Mầm xanh',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vai trò:', style: TextStyle(fontSize: 13, color: AppColors.subText)),
                        Text('Chủ hộ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Trạng thái:', style: TextStyle(fontSize: 13, color: AppColors.subText)),
                        Text('Đang hoạt động', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D4F3C))),
                      ],
                    ),
                  ],
                ),
              ),
              buttonText: 'Về trang chủ gia đình',
              buttonIcon: Icons.home_outlined,
              onButtonPressed: () {
                context.go('/');
              },
              bottomWidget: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/family_gardening.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Đây là trạng thái hoàn tất minh họa, bạn có thể mời thêm thành viên vào bất kỳ lúc nào.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.greyText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/family/scan-qr',
      builder: (context, state) => const ScanHouseholdQrScreen(),
    ),
    GoRoute(
      path: '/family/lookup-result',
      builder: (context, state) {
        final householdId = state.extra as String? ?? '';
        return BlocProvider(
          create: (_) => getIt<HouseholdLookupCubit>(),
          child: HouseholdLookupResultScreen(householdId: householdId),
        );
      },
    ),
    GoRoute(
      path: '/family/invitations/sent',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<SentInvitationsCubit>(),
        child: const SentInvitationsScreen(),
      ),
    ),
    GoRoute(
      path: '/family/join-requests',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<HouseholdJoinRequestsCubit>(),
        child: const HouseholdJoinRequestsScreen(),
      ),
    ),
    GoRoute(
      path: '/family/invite-user',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<InviteUserCubit>(),
        child: const InviteUserScreen(),
      ),
    ),
    GoRoute(
      path: '/family/qr',
      builder: (context, state) => const HouseholdQrScreen(),
    ),
    GoRoute(
      path: '/family/invitations/received',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ReceivedInvitationsCubit>(),
        child: const ReceivedInvitationsScreen(),
      ),
      routes: [
        GoRoute(
          path: 'detail',
          builder: (context, state) {
            final invitation = state.extra as HouseholdInvitation;
            return BlocProvider(
              create: (_) => getIt<ReceivedInvitationsCubit>(),
              child: ReceivedInvitationDetailScreen(invitation: invitation),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/family/join-requests/my',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<MyJoinRequestsCubit>(),
        child: const MyJoinRequestsScreen(),
      ),
    ),
    GoRoute(
      path: '/family/owner-permissions',
      builder: (context, state) => const OwnerPermissionsScreen(),
      routes: [
        GoRoute(
          path: 'transfer',
          builder: (context, state) => const TransferOwnershipScreen(),
        ),
        GoRoute(
          path: 'remove-members',
          builder: (context, state) => const RemoveMembersScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/common-success',
      builder: (context, state) {
        final args = state.extra as CustomSuccessArgs;
        return CustomSuccessScreen.fromArgs(args: args);
      },
    ),
    GoRoute(
      path: '/emission/history',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FamilyEmissionHistoryScreen(
          initialYear: extra?['year'] as int?,
          initialMonth: extra?['month'] as int?,
        );
      },
    ),
    GoRoute(
      path: '/emission/select-type',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SelectEmissionTypeScreen(
          year: extra?['year'] as int?,
          month: extra?['month'] as int?,
          initialCategory: extra?['category'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/emission/entry',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SelectEmissionTypeScreen(
          year: extra?['year'] as int?,
          month: extra?['month'] as int?,
          initialCategory: extra?['category'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/emission/quick-calc/select-type',
      builder: (context, state) {
        return const SelectEmissionTypeScreen(
          isQuickCalc: true,
        );
      },
    ),
    GoRoute(
      path: '/emission/quick-calc/electricity',
      builder: (context, state) => const QuickCalcElectricityScreen(),
    ),
    GoRoute(
      path: '/emission/quick-calc/transportation',
      builder: (context, state) => const QuickCalcTransportationScreen(),
    ),
    GoRoute(
      path: '/emission/quick-calc/refrigerant',
      builder: (context, state) => const QuickCalcRefrigerantScreen(),
    ),
    GoRoute(
      path: '/emission/quick-calc/waste',
      builder: (context, state) => const QuickCalcWasteScreen(),
    ),
    GoRoute(
      path: '/emission/quick-calc/gas',
      builder: (context, state) => const QuickCalcGasScreen(),
    ),
    GoRoute(
      path: '/emission/input/electricity',
      builder: (context, state) {
        final extra = state.extra is Map<String, dynamic>
            ? state.extra as Map<String, dynamic>
            : null;
        final editRecord = state.extra is HouseholdEmission
            ? state.extra as HouseholdEmission
            : extra?['editRecord'] as HouseholdEmission?;
        return InputElectricityEmissionScreen(
          initialYear: editRecord?.periodYear ?? extra?['year'] as int?,
          initialMonth: editRecord?.periodMonth ?? extra?['month'] as int?,
          editRecord: editRecord,
        );
      },
    ),
    GoRoute(
      path: '/emission/input/transportation',
      builder: (context, state) {
        final extra = state.extra is Map<String, dynamic>
            ? state.extra as Map<String, dynamic>
            : null;
        final editRecord = state.extra is HouseholdEmission
            ? state.extra as HouseholdEmission
            : extra?['editRecord'] as HouseholdEmission?;
        return InputTransportationEmissionScreen(
          initialYear: editRecord?.periodYear ?? extra?['year'] as int?,
          initialMonth: editRecord?.periodMonth ?? extra?['month'] as int?,
          editRecord: editRecord,
        );
      },
    ),
    GoRoute(
      path: '/emission/input/gas',
      builder: (context, state) {
        final extra = state.extra is Map<String, dynamic>
            ? state.extra as Map<String, dynamic>
            : null;
        final editRecord = state.extra is HouseholdEmission
            ? state.extra as HouseholdEmission
            : extra?['editRecord'] as HouseholdEmission?;
        return InputGasEmissionScreen(
          initialYear: editRecord?.periodYear ?? extra?['year'] as int?,
          initialMonth: editRecord?.periodMonth ?? extra?['month'] as int?,
          editRecord: editRecord,
        );
      },
    ),
    GoRoute(
      path: '/emission/input/refrigerant',
      builder: (context, state) {
        final extra = state.extra is Map<String, dynamic>
            ? state.extra as Map<String, dynamic>
            : null;
        final editRecord = state.extra is HouseholdEmission
            ? state.extra as HouseholdEmission
            : extra?['editRecord'] as HouseholdEmission?;
        return InputRefrigerantEmissionScreen(
          initialYear: editRecord?.periodYear ?? extra?['year'] as int?,
          initialMonth: editRecord?.periodMonth ?? extra?['month'] as int?,
          editRecord: editRecord,
        );
      },
    ),
    GoRoute(
      path: '/emission/input/waste',
      builder: (context, state) {
        final extra = state.extra is Map<String, dynamic>
            ? state.extra as Map<String, dynamic>
            : null;
        final editRecord = state.extra is HouseholdEmission
            ? state.extra as HouseholdEmission
            : extra?['editRecord'] as HouseholdEmission?;
        return InputWasteEmissionScreen(
          initialYear: editRecord?.periodYear ?? extra?['year'] as int?,
          initialMonth: editRecord?.periodMonth ?? extra?['month'] as int?,
          editRecord: editRecord,
        );
      },
    ),
    GoRoute(
      path: '/emission/waste/select-type',
      builder: (context, state) {
        final selected = state.extra as WasteTypeItem?;
        return SelectWasteTypeScreen(initialSelected: selected);
      },
    ),
    GoRoute(
      path: '/emission/preview',
      builder: (context, state) {
        final args = state.extra as EmissionPreviewArgs;
        return EmissionPreviewScreen(args: args);
      },
    ),
    GoRoute(
      path: '/emission/record-detail',
      builder: (context, state) {
        final record = state.extra as HouseholdEmission?;
        return EmissionRecordDetailScreen(record: record);
      },
    ),
    GoRoute(
      path: '/emission/record-edit',
      builder: (context, state) {
        final record = state.extra as HouseholdEmission?;
        return EmissionRecordEditScreen(record: record);
      },
    ),
    GoRoute(
      path: '/input-electricity',
      builder: (context, state) => const FamilyEmissionHistoryScreen(),
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
      path: '/incidents',
      builder: (context, state) => const IncidentListScreen(showBackButton: true),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const CreateIncidentScreen(),
        ),
        GoRoute(
          path: 'add-evidence',
          builder: (context, state) => CreateIncidentScreen(
            incidentToAppend: state.extra as Incident?,
          ),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => IncidentDetailScreen(
            incidentId: state.pathParameters['id']!,
            initialIncident: state.extra as Incident?,
          ),
        ),
      ],
    ),
  ],
);

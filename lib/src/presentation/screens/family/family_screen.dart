import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/household/household_cubit.dart';
import '../../blocs/household/household_state.dart';
import 'views/household_empty_view.dart';
import 'views/household_member_view.dart';
import 'views/household_owner_view.dart';
import '../../widgets/custom_app_bar.dart';
import 'widgets/household_shimmer_loading.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final householdCubit = context.read<HouseholdCubit>();
      if (householdCubit.state.status == HouseholdStatus.initial) {
        final authState = context.read<AuthBloc>().state;
        final userId = authState is AuthAuthenticated ? authState.user.id : null;
        householdCubit.loadHouseholdData(userId: userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocBuilder<HouseholdCubit, HouseholdState>(
          builder: (context, state) {
            Widget content;

            if (state.status == HouseholdStatus.initial ||
                (state.status == HouseholdStatus.loading && state.household == null)) {
              content = const HouseholdShimmerLoading();
            } else if (state.status == HouseholdStatus.error && state.household == null) {
              content = SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    const CustomAppBar(
                      title: 'Gia đình',
                      subtitle: 'Quản lý thành viên và kết nối hộ gia đình.',
                      showBackButton: false,
                    ),
                    const SizedBox(height: 60),
                    const Icon(Icons.wifi_off_rounded, size: 54, color: AppColors.greyText),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Không thể tải thông tin gia đình.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.subText),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        final userId = authState is AuthAuthenticated ? authState.user.id : null;
                        context.read<HouseholdCubit>().loadHouseholdData(userId: userId);
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            } else if (state.isFreeUser) {
              content = HouseholdEmptyView(state: state);
            } else if (state.isOwner) {
              content = HouseholdOwnerView(state: state);
            } else {
              content = HouseholdMemberView(state: state);
            }

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.white,
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                final userId = authState is AuthAuthenticated ? authState.user.id : null;
                await context.read<HouseholdCubit>().loadHouseholdData(userId: userId);
              },
              child: content,
            );
          },
        ),
      ),
    );
  }
}

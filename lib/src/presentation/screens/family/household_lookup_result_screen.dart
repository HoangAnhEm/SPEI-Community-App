import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/household_lookup_result.dart';
import '../../blocs/household/household_cubit.dart';
import '../../blocs/household_lookup/household_lookup_cubit.dart';
import '../../blocs/household_lookup/household_lookup_state.dart';
import '../../widgets/custom_app_bar.dart';

// Màu riêng của màn này
const Color _kGreenD2E4CA = Color(0xFFD2E4CA);
const Color _kOrangeLightF8E7CD = Color(0xFFF8E7CD);

class HouseholdLookupResultScreen extends StatefulWidget {
  final String householdId;

  const HouseholdLookupResultScreen({super.key, required this.householdId});

  @override
  State<HouseholdLookupResultScreen> createState() => _HouseholdLookupResultScreenState();
}

class _HouseholdLookupResultScreenState extends State<HouseholdLookupResultScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HouseholdLookupCubit>().lookupHousehold(widget.householdId);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'HG';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;
    final householdState = context.watch<HouseholdCubit>().state;
    final currentHousehold = householdState.household;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Tìm thấy hộ gia đình',
              subtitle: 'Kiểm tra thông tin trước khi gửi yêu cầu.',
              showBackButton: true,
            ),
            Expanded(
              child: BlocConsumer<HouseholdLookupCubit, HouseholdLookupState>(
                listener: (context, state) {
                  if (state is HouseholdLookupSuccess && state.joinSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gửi yêu cầu tham gia hộ gia đình thành công!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    context.pop();
                  }
                },
                builder: (context, state) {
                  if (state is HouseholdLookupLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is HouseholdLookupFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 60, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              state.error,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: AppColors.darkText),
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                context.read<HouseholdLookupCubit>().lookupHousehold(widget.householdId);
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  'Thử lại',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Quét hộ khác', style: TextStyle(color: AppColors.textGreenMedium)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is HouseholdLookupSuccess) {
                    final result = state.result;
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card 1: Hộ gia đình SPEI (Ảnh 2)
                          _buildHouseholdInfoCard(result),
                          const SizedBox(height: 16),

                          // Card 2: ID hộ gia đình
                          _buildHouseholdIdCard(result.householdId),
                          const SizedBox(height: 16),

                          // Card 3: Nhắc nhở về việc gửi yêu cầu (Tuỳ người dùng đang có trong hộ hay chưa)
                          _buildEligibilityReminderCard(
                            result: result,
                            currentHouseholdName: currentHousehold?.name,
                          ),
                          const SizedBox(height: 24),

                          // Banner lỗi gửi yêu cầu nếu có
                          if (state.joinError != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.errorBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.redBorder),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      state.joinError!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.error,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Nút 1: Gửi yêu cầu tham gia
                          InkWell(
                            onTap: state.isJoining
                                ? null
                                : () {
                                    if (!result.canRequest && result.reason != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(result.reason!)),
                                      );
                                      return;
                                    }
                                    context
                                        .read<HouseholdLookupCubit>()
                                        .sendJoinRequest(result.householdId);
                                  },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: result.canRequest ? AppColors.primary : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: state.isJoining
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.near_me_outlined, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Gửi yêu cầu tham gia',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Nút 2: Quét hộ khác
                          InkWell(
                            onTap: () => context.pop(),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Center(
                                child: Text(
                                  'Quét hộ khác',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textGreenMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Footer
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdInfoCard(HouseholdLookupResult result) {
    final initials = _getInitials(result.ownerName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hộ gia đình SPEI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            result.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${result.memberCount} thành viên',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subText,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _kGreenD2E4CA),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.ownerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Chủ hộ • spei.community',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdIdCard(String householdId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ID hộ gia đình',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.subText,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            householdId,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityReminderCard({
    required HouseholdLookupResult result,
    required String? currentHouseholdName,
  }) {
    // Trường hợp 1: Có lý do không thể yêu cầu (ví dụ: đã gửi yêu cầu trước đó hoặc là chủ hộ)
    if (!result.canRequest && result.reason != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.redBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result.reason!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.error,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Trường hợp 2: Người dùng đang ở trong 1 hộ khác (Variant B - Thẻ màu vàng)
    if (currentHouseholdName != null && currentHouseholdName.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.amberSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kOrangeLightF8E7CD),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.brownText, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bạn đang ở $currentHouseholdName. Bạn vẫn có thể gửi yêu cầu đến ${result.name}, nhưng phải rời hộ hiện tại trước khi tham gia.',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.oliveText,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Trường hợp 3: Người dùng tự do / Chưa có hộ (Variant A - Thẻ màu xanh)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Yêu cầu sẽ được gửi đến chủ hộ ${result.ownerName}. Bạn chỉ trở thành thành viên sau khi được chấp nhận.',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textGreenMedium,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

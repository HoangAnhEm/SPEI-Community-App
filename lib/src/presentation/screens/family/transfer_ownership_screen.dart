import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/household.dart';
import '../../blocs/household/household_cubit.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_confirm_dialog.dart';

class TransferOwnershipScreen extends StatefulWidget {
  const TransferOwnershipScreen({super.key});

  @override
  State<TransferOwnershipScreen> createState() => _TransferOwnershipScreenState();
}

class _TransferOwnershipScreenState extends State<TransferOwnershipScreen> {
  HouseholdMember? _selectedMember;

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'TV';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _onContinuePressed(BuildContext context, String householdName) {
    if (_selectedMember == null) return;
    final selected = _selectedMember!;

    CustomConfirmDialog.show(
      context: context,
      title: 'Chuyển quyền cho ${selected.fullName}?',
      content:
          '${selected.fullName} sẽ là Chủ hộ $householdName. Bạn chuyển thành Thành viên và vẫn ở trong hộ; thao tác này không tự rời hộ.',
      confirmText: 'Xác nhận chuyển quyền',
      cancelText: 'Hủy',
      isDestructive: false,
      onConfirm: () async {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final router = GoRouter.of(context);
        final householdCubit = context.read<HouseholdCubit>();

        final success = await householdCubit.transferOwnership(selected.userId);
        if (success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Đã chuyển quyền chủ hộ cho ${selected.fullName} thành công'),
              backgroundColor: AppColors.primary,
            ),
          );
          router.go('/');
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(householdCubit.state.errorMessage ?? 'Không thể chuyển quyền chủ hộ'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final householdState = context.watch<HouseholdCubit>().state;
    final household = householdState.household;
    final householdName = household?.name ?? 'Nhà Mầm xanh';

    // Lọc các thành viên không phải là chủ hộ hiện tại
    final eligibleMembers = household?.members.where((m) => !m.isOwner).toList() ?? [];

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Chuyển quyền chủ hộ',
              subtitle: 'Chọn một thành viên của $householdName để tiếp quản.',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hộp thông báo màu vàng nhạt (Ảnh 1 giữa)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.amberSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.orange200),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.greenPrimary,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sau khi chuyển, bạn sẽ trở thành Thành viên. Người được chọn sẽ quản lý lời mời và duyệt yêu cầu vào hộ.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.brownText,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tiêu đề phần chọn
                    const Text(
                      'Chọn chủ hộ mới',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Danh sách thành viên
                    if (eligibleMembers.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.group_off_outlined, size: 36, color: AppColors.greyText),
                            SizedBox(height: 8),
                            Text(
                              'Không có thành viên nào khác trong hộ để chuyển quyền.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppColors.subText),
                            ),
                          ],
                        ),
                      )
                    else
                      ...eligibleMembers.map((member) {
                        final isSelected = _selectedMember?.userId == member.userId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMember = member;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Avatar chữ viết tắt
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.greenSurfacePale,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getInitials(member.fullName),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textGreenMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Thông tin tên & email
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.fullName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Thành viên • ${member.email.isNotEmpty ? member.email : (member.phoneNumber ?? '')}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.subText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Icon check khi chọn
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.greenPrimary,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 16),

                    // Dòng trạng thái khi đã chọn
                    if (_selectedMember != null)
                      Center(
                        child: Text(
                          'Đã chọn ${_selectedMember!.fullName}. Hộ chỉ có một Chủ hộ.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                        ),
                      ),

                    const SizedBox(height: 14),

                    // Nút tiếp tục chuyển quyền
                    InkWell(
                      onTap: _selectedMember != null && !householdState.isActionLoading
                          ? () => _onContinuePressed(context, householdName)
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedMember != null ? AppColors.primary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: householdState.isActionLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Tiếp tục chuyển quyền',
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
                    const SizedBox(height: 24),

                    // Footer
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

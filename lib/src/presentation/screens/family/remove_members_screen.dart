import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/household/household_cubit.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_confirm_dialog.dart';

// Màu riêng của màn này
const Color _kRed9E4738 = Color(0xFF9E4738);

class RemoveMembersScreen extends StatefulWidget {
  const RemoveMembersScreen({super.key});

  @override
  State<RemoveMembersScreen> createState() => _RemoveMembersScreenState();
}

class _RemoveMembersScreenState extends State<RemoveMembersScreen> {
  final Set<String> _selectedMemberIds = {};

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'TV';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _onRemovePressed(BuildContext context, String householdName, int count) {
    if (_selectedMemberIds.isEmpty) return;

    CustomConfirmDialog.show(
      context: context,
      title: 'Xóa $count thành viên khỏi hộ?',
      content:
          'Những thành viên đã chọn sẽ không còn thuộc hộ $householdName và có thể tham gia các hộ khác. Thao tác này không thể hoàn tác.',
      confirmText: 'Xác nhận xóa',
      cancelText: 'Hủy',
      isDestructive: true,
      onConfirm: () async {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final router = GoRouter.of(context);
        final householdCubit = context.read<HouseholdCubit>();

        final success = await householdCubit.removeMembers(_selectedMemberIds.toList());
        if (success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Đã xóa $count thành viên khỏi hộ gia đình thành công'),
              backgroundColor: AppColors.primary,
            ),
          );
          router.pop();
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(householdCubit.state.errorMessage ?? 'Không thể xóa thành viên'),
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

    final selectedMembers = eligibleMembers.where((m) => _selectedMemberIds.contains(m.userId)).toList();
    final remainingCount = (household?.memberCount ?? 1) - _selectedMemberIds.length;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Xoá thành viên',
              subtitle: 'Chọn thành viên của $householdName muốn xoá.',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hộp thông báo màu vàng nhạt (Ảnh 1 phải)
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
                            Icons.info_outline,
                            color: AppColors.greenPrimary,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sau khi xoá những thành viên khỏi hộ, những thành viên mới có thể tham gia các hộ gia đình khác',
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
                      'Chọn thành viên muốn xoá',
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
                              'Không có thành viên nào khác trong hộ để xóa.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppColors.subText),
                            ),
                          ],
                        ),
                      )
                    else
                      ...eligibleMembers.map((member) {
                        final isSelected = _selectedMemberIds.contains(member.userId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedMemberIds.remove(member.userId);
                                } else {
                                  _selectedMemberIds.add(member.userId);
                                }
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
                                  color: isSelected ? AppColors.error : AppColors.borderLight,
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
                                      color: _kRed9E4738,
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
                    if (selectedMembers.isNotEmpty)
                      Center(
                        child: Text(
                          selectedMembers.length == 1
                              ? 'Đã chọn ${selectedMembers.first.fullName}. Hộ sẽ chỉ còn $remainingCount người'
                              : 'Đã chọn ${selectedMembers.length} thành viên. Hộ sẽ chỉ còn $remainingCount người',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                        ),
                      ),

                    const SizedBox(height: 14),

                    // Nút xóa thành viên đã chọn
                    InkWell(
                      onTap: _selectedMemberIds.isNotEmpty && !householdState.isActionLoading
                          ? () => _onRemovePressed(context, householdName, _selectedMemberIds.length)
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedMemberIds.isNotEmpty
                              ? _kRed9E4738
                              : Colors.grey.shade300,
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
                                    Icon(Icons.delete_outline, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Xóa thành viên đã chọn',
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

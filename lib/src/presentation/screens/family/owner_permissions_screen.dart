import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/household/household_cubit.dart';
import '../../widgets/custom_app_bar.dart';

class OwnerPermissionsScreen extends StatefulWidget {
  const OwnerPermissionsScreen({super.key});

  @override
  State<OwnerPermissionsScreen> createState() => _OwnerPermissionsScreenState();
}

class _OwnerPermissionsScreenState extends State<OwnerPermissionsScreen> {
  void _showDeleteHouseholdDialog(BuildContext context, String householdName, int memberCount) {
    final nameController = TextEditingController();
    bool isMatch = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFFF9FAF7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xóa $householdName?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Cảnh báo màu đỏ nhạt (Ảnh 2)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFC94A4A), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hộ sẽ bị xóa; bạn và ${memberCount > 1 ? '${memberCount - 1} thành viên khác' : 'các thành viên'} không còn thuộc hộ này. Hãy trao đổi với cả nhà trước khi tiếp tục.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9B1C1C),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Nhập tên hộ để xác nhận',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: householdName,
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8DE)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8DE)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          isMatch = val.trim() == householdName.trim();
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Nút 1: Giữ lại hộ
                    InkWell(
                      onTap: () => Navigator.of(dialogCtx).pop(),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8DE)),
                        ),
                        child: const Center(
                          child: Text(
                            'Giữ lại hộ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Nút 2: Xác nhận xóa hộ
                    InkWell(
                      onTap: isMatch
                          ? () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final router = GoRouter.of(context);
                              final householdCubit = context.read<HouseholdCubit>();
                              Navigator.of(dialogCtx).pop();

                              final success = await householdCubit.deleteHousehold();
                              if (success) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã giải tán hộ gia đình thành công'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                                router.go('/');
                              } else {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(householdCubit.state.errorMessage ?? 'Không thể xóa hộ gia đình'),
                                    backgroundColor: const Color(0xFFC94A4A),
                                  ),
                                );
                              }
                            }
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isMatch ? const Color(0xFFFDE8E8) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Xác nhận xóa hộ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isMatch ? const Color(0xFFC94A4A) : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final householdState = context.watch<HouseholdCubit>().state;
    final household = householdState.household;

    final householdName = household?.name ?? 'Nhà Mầm xanh';
    final ownerName = household?.owner?.fullName ?? '';
    final memberCount = household?.memberCount ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Quyền chủ hộ',
              subtitle: ownerName.isNotEmpty ? '$householdName • $ownerName' : householdName,
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card thông tin Bạn là chủ hộ (Ảnh 1 bên trái)
                    Container(
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
                            'Bạn là chủ hộ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF03543F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            householdName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$memberCount thành viên hiện tại',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.subText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cảnh báo màu vàng nhạt (Ảnh 1 bên trái)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF6E8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_outlined, color: Color(0xFFD97706), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Chủ hộ không thể rời hộ trực tiếp. Bạn cần chuyển quyền cho một thành viên hiện tại hoặc xóa hộ gia đình trước.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A6D3B),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Chuyển quyền chủ hộ
                    _buildActionCard(
                      icon: Icons.person_outline,
                      iconColor: AppColors.primary,
                      title: 'Chuyển quyền chủ hộ',
                      subtitle: 'Chọn thành viên làm chủ hộ mới',
                      onTap: () {
                        context.push('/family/owner-permissions/transfer');
                      },
                    ),
                    const SizedBox(height: 12),

                    // 2. Xoá thành viên
                    _buildActionCard(
                      icon: Icons.person_remove_outlined,
                      iconColor: const Color(0xFFC94A4A),
                      title: 'Xoá thành viên',
                      subtitle: 'Xoá thành viên khỏi hộ gia đình',
                      onTap: () {
                        context.push('/family/owner-permissions/remove-members');
                      },
                    ),
                    const SizedBox(height: 20),

                    // Card Muốn xoá hộ gia đình?
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8ECE5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Muốn xoá hộ gia đình?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Chỉ xóa khi bạn chắc chắn cả nhà không còn sử dụng hộ này.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.subText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => _showDeleteHouseholdDialog(context, householdName, memberCount),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8E8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.delete_outline, color: Color(0xFFC94A4A), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Xóa $householdName',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFC94A4A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8ECE5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.subText, size: 20),
          ],
        ),
      ),
    );
  }
}

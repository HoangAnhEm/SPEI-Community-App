import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../../domain/entities/reward.dart';
import '../../blocs/reward/reward_cubit.dart';
import '../../blocs/reward/reward_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';

// Màu riêng của màn này
const Color _kRedEF9A9A = Color(0xFFEF9A9A);

class RewardDetailScreen extends StatelessWidget {
  final RewardItem? reward;

  const RewardDetailScreen({
    super.key,
    this.reward,
  });

  RewardItem _resolveReward(RewardState state) {
    if (reward != null) return reward!;
    if (state.rewards.isNotEmpty) return state.rewards.first;
    return const RewardItem(
      id: 'default',
      title: 'Bộ trồng cây',
      description: 'Gồm chậu đất nung, hạt giống, đất trồng và xẻng nhỏ. Dành cho bé từ 6 tuổi, cùng người lớn gieo hạt và chăm cây.',
      costPoints: 800,
      stockQuantity: 10,
      status: RewardStatus.published,
      imageUrl: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RewardCubit, RewardState>(
      builder: (context, state) {
        final currentReward = _resolveReward(state);
        final balance = state.balance;
        final formattedBalance = state.formattedBalance;
        final costPoints = currentReward.costPoints;
        final formattedCost = currentReward.formattedPoints;
        final remaining = balance - costPoints;
        final isEnoughPoints = balance >= costPoints;
        final isOutOfStock = currentReward.isOutOfStock;
        final isRedeeming = state.isRedeeming;

        final formattedRemaining = remaining >= 0
            ? remaining.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]}.',
                )
            : '0';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                CustomAppBar(
                  title: currentReward.title,
                  subtitle: 'Một hạt nhỏ, một vườn vui',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _buildRewardImage(currentReward.imageUrl, currentReward.title, height: 200),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                currentReward.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$formattedCost điểm',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (currentReward.description != null && currentReward.description!.isNotEmpty) ...[
                          Text(
                            currentReward.description!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.subText,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Thông tin tồn kho & trạng thái
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isOutOfStock ? AppColors.redSurfaceLight : AppColors.neutral25,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isOutOfStock ? _kRedEF9A9A : AppColors.divider,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isOutOfStock ? Icons.info_outline : Icons.inventory_2_outlined,
                                size: 16,
                                color: isOutOfStock ? AppColors.red700 : AppColors.subText,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isOutOfStock
                                    ? 'Phần quà này tạm thời đã hết hàng'
                                    : 'Số lượng còn lại: ${currentReward.stockQuantity} phần quà',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isOutOfStock ? AppColors.red700 : AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTransactionCard(
                          title: currentReward.title,
                          formattedBalance: formattedBalance,
                          formattedCost: formattedCost,
                          formattedRemaining: formattedRemaining,
                          isEnoughPoints: isEnoughPoints,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Đây là trạng thái sau đổi trong bản mẫu; chưa trừ điểm hay tạo đơn nhận quà thực tế.',
                          style: TextStyle(fontSize: 10, color: AppColors.subText),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: isRedeeming
                              ? 'Đang đổi quà...'
                              : (isOutOfStock
                                  ? 'Hết hàng'
                                  : (!isEnoughPoints ? 'Chưa đủ điểm để đổi' : 'Đổi quà')),
                          isLoading: isRedeeming,
                          isDisabled: isOutOfStock,
                          onPressed: () {
                            if (isOutOfStock || isRedeeming) return;
                            if (!isEnoughPoints) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Bạn còn thiếu ${(-remaining).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} điểm để đổi món quà này.',
                                  ),
                                  backgroundColor: Colors.orange.shade800,
                                ),
                              );
                              return;
                            }
                            _showConfirmDialog(context, currentReward);
                          },
                        ),
                        const SizedBox(height: 24),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String formattedBalance,
    required String formattedCost,
    required String formattedRemaining,
    required bool isEnoughPoints,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điểm sau khi đổi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trước khi đổi',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              Text(
                '$formattedBalance điểm',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$title × 1',
                  style: const TextStyle(fontSize: 12, color: AppColors.subText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '−$formattedCost điểm',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Còn lại',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isEnoughPoints ? AppColors.primary : Colors.red,
                ),
              ),
              Text(
                '$formattedRemaining điểm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isEnoughPoints ? AppColors.primary : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, RewardItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.redeem, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Xác nhận đổi quà',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn dùng ${item.formattedPoints} điểm để đổi món quà "${item.title}" không?',
            style: const TextStyle(fontSize: 13, color: AppColors.darkText, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Hủy', style: TextStyle(color: AppColors.subText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                _handleRedeem(context, item);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRedeem(BuildContext context, RewardItem item) async {
    final cubit = context.read<RewardCubit>();
    final order = await cubit.redeemReward(item.id);

    if (!context.mounted) return;

    if (order != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đổi quà thành công! Mã voucher: ${order.voucherCode ?? order.orderCode}',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
        ),
      );
      // Quay về trang danh sách quà (RewardStoreScreen)
      context.pop();
    } else {
      final error = cubit.state.redeemErrorMessage ?? 'Đổi quà thất bại. Vui lòng thử lại sau.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(error)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildRewardImage(String? imageUrl, String title, {double height = 200}) {
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      return Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAsset(title, height),
      );
    }
    return _buildFallbackAsset(title, height);
  }

  Widget _buildFallbackAsset(String title, double height) {
    final lower = title.toLowerCase();
    String asset = 'assets/images/plant.png';
    if (lower.contains('bình') || lower.contains('chai') || lower.contains('nước')) {
      asset = 'assets/images/bottle.png';
    } else if (lower.contains('sách') || lower.contains('vở') || lower.contains('truyện')) {
      asset = 'assets/images/book.png';
    } else if (lower.contains('túi') || lower.contains('vải') || lower.contains('balo')) {
      asset = 'assets/images/bag.png';
    }

    return Image.asset(
      asset,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: double.infinity,
        color: AppColors.neutral50,
        child: const Icon(Icons.local_florist, size: 64, color: AppColors.subText),
      ),
    );
  }
}

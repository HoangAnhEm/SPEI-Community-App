import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../../domain/entities/reward.dart';
import '../../blocs/reward/reward_cubit.dart';
import '../../blocs/reward/reward_state.dart';
import '../../widgets/custom_app_bar.dart';

class RewardStoreScreen extends StatelessWidget {
  const RewardStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Quà xanh cho nhà',
              subtitle: 'Tích thói quen tốt, đổi niềm vui nhỏ',
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await context.read<RewardCubit>().loadRewardData(silent: true);
                },
                child: BlocBuilder<RewardCubit, RewardState>(
                  builder: (context, state) {
                    final balance = state.balance;
                    final formattedBalance = state.formattedBalance;
                    final selectedFilter = state.selectedFilter;
                    final items = state.filteredRewards;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBalanceCard(formattedBalance),
                          const SizedBox(height: 20),
                          _buildFilterTabs(context, selectedFilter),
                          const SizedBox(height: 20),
                          _buildMotivationBanner(),
                          const SizedBox(height: 20),
                          if (state.status == RewardLoadingStatus.loading && state.rewards.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            )
                          else if (items.isEmpty)
                            _buildEmptyState(context, selectedFilter)
                          else
                            _buildRewardGrid(context, items, balance),
                          const SizedBox(height: 32),
                          const Text(
                            'Danh mục, giá điểm và hình ảnh là ví dụ. Bản mẫu chưa có dịch vụ cung cấp hoặc giao quà.',
                            style: TextStyle(fontSize: 10, color: AppColors.subText),
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String formattedBalance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/ic_leaf_outline.png',
            width: 32,
            height: 32,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.eco_outlined, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Điểm xanh hiện có',
                  style: TextStyle(fontSize: 11, color: AppColors.subText),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedBalance,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'điểm',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/icons/ic_history.png',
            width: 24,
            height: 24,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.history, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, String selectedFilter) {
    return Row(
      children: [
        _buildFilterChip(
          text: 'Tất cả',
          isSelected: selectedFilter == 'all',
          onTap: () {
            context.read<RewardCubit>().setFilter('all');
          },
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          text: 'Có thể đổi',
          isSelected: selectedFilter == 'affordable',
          onTap: () {
            context.read<RewardCubit>().setFilter('affordable');
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.successBg : AppColors.neutral100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : AppColors.subText,
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationBanner() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.successBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/mam_ai_avatar.png',
              width: 42,
              height: 42,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.eco, color: Colors.green, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Một món quà, thêm một cách để cả nhà sống xanh!',
            style: TextStyle(fontSize: 13, color: AppColors.subText),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardGrid(BuildContext context, List<RewardItem> items, int balance) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.63,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGiftCard(context: context, item: item, balance: balance);
      },
    );
  }

  Widget _buildGiftCard({
    required BuildContext context,
    required RewardItem item,
    required int balance,
  }) {
    final bool isOutOfStock = item.isOutOfStock;
    final bool isEnoughPoints = item.canAfford(balance);
    final int pointsShort = item.costPoints - balance;

    // Trạng thái quà tặng hiển thị
    String statusBadgeText;
    Color statusBgColor;
    Color statusTextColor;

    if (isOutOfStock) {
      statusBadgeText = 'Hết hàng';
      statusBgColor = AppColors.redSurfaceLight;
      statusTextColor = AppColors.red700;
    } else if (isEnoughPoints) {
      statusBadgeText = 'Đủ điểm • Xem quà';
      statusBgColor = AppColors.successBg;
      statusTextColor = AppColors.primary;
    } else {
      final shortFormatted = pointsShort.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      statusBadgeText = 'Thiếu $shortFormatted điểm';
      statusBgColor = AppColors.neutral100;
      statusTextColor = AppColors.subText;
    }

    return GestureDetector(
      onTap: () {
        context.push('/reward-detail', extra: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh quà kèm badge trạng thái kho
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildRewardImage(item.imageUrl, item.title, height: 120),
                ),
                // Badge tồn kho góc trên ảnh
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? AppColors.red700.withValues(alpha: 0.9)
                          : Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isOutOfStock ? 'Hết quà' : 'Còn ${item.stockQuantity}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description ?? 'Quà tặng SPEI Community',
                    style: const TextStyle(fontSize: 10, color: AppColors.subText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        item.formattedPoints,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'điểm',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusBadgeText,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardImage(String? imageUrl, String title, {double height = 120}) {
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
        child: const Icon(Icons.eco, size: 40, color: AppColors.subText),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String selectedFilter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.neutral50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.subText),
            ),
            const SizedBox(height: 16),
            Text(
              selectedFilter == 'affordable'
                  ? 'Chưa có phần quà nào đủ điểm để đổi'
                  : 'Hiện tại chưa có phần quà nào',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedFilter == 'affordable'
                  ? 'Hãy tích luỹ thêm điểm xanh từ các hoạt động bảo vệ môi trường nhé!'
                  : 'Vui lòng quay lại sau khi danh mục quà tặng được cập nhật.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.subText),
            ),
          ],
        ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class RewardDetailScreen extends StatelessWidget {
  const RewardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Bộ trồng cây',
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
                      child: Image.asset(
                        'assets/images/plant.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          width: double.infinity,
                          color: const Color(0xFFF5F5F5),
                          child: const Icon(Icons.local_florist, size: 64, color: AppColors.subText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bộ trồng cây',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '800 điểm',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gồm chậu đất nung, hạt giống, đất trồng và xẻng nhỏ. Dành cho bé từ 6 tuổi, cùng người lớn gieo hạt và chăm cây.',
                      style: TextStyle(fontSize: 13, color: AppColors.subText, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    _buildTransactionCard(),
                    const SizedBox(height: 16),
                    _buildDeliveryCard(),
                    const SizedBox(height: 16),
                    _buildSuccessCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Đây là trạng thái sau đổi trong bản mẫu; chưa trừ điểm hay tạo đơn nhận quà thực tế.',
                      style: TextStyle(fontSize: 10, color: AppColors.subText),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Bản mẫu giao diện • Dữ liệu minh họa',
                        style: TextStyle(fontSize: 10, color: AppColors.greyText),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard() {
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trước khi đổi',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              const Text(
                '1.250 điểm',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ trồng cây × 1',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              const Text(
                '−800 điểm',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Còn lại',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const Text(
                '450 điểm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nhận quà tại điểm hẹn',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              Image.asset(
                'assets/icons/ic_edit.png',
                width: 16,
                height: 16,
                color: AppColors.primary,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Nguyễn Thị Lan • 09** *** 218',
            style: TextStyle(fontSize: 12, color: AppColors.darkText),
          ),
          const SizedBox(height: 8),
          const Text(
            'Điểm cộng đồng SPEI, Bình Thạnh (ví dụ). Khung giờ dự kiến: 09:00–11:00, 12/10.',
            style: TextStyle(fontSize: 12, color: AppColors.subText, height: 1.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Thông tin nhận quà minh họa, không phải lịch hẹn thật.',
            style: TextStyle(fontSize: 10, color: AppColors.subText),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/icons/ic_check.png',
                  width: 16,
                  height: 16,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đã xác nhận đổi quà',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Trạng thái minh họa • QX-1008',
                    style: TextStyle(fontSize: 10, color: AppColors.subText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '1 bộ trồng cây • Số dư mới 450 điểm. Cả nhà sẵn sàng gieo mầm nhé!',
            style: TextStyle(fontSize: 12, color: AppColors.darkText, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Xem phiếu nhận quà',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

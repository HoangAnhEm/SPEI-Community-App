import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_app_bar.dart';

class InputElectricityScreen extends StatefulWidget {
  const InputElectricityScreen({super.key});

  @override
  State<InputElectricityScreen> createState() => _InputElectricityScreenState();
}

class _InputElectricityScreenState extends State<InputElectricityScreen> {
  final TextEditingController _kwhController = TextEditingController(text: '250');

  @override
  void dispose() {
    _kwhController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Điện nhà mình',
              subtitle: 'Một con số, một bước xanh',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBanner(),
                    const SizedBox(height: 24),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildHelpCard(),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Tính phát thải ước tính',
                      iconPath: 'assets/icons/ic_calculator.png',
                      fallbackIcon: Icons.calculate_outlined,
                      onPressed: () {
                        context.push('/electricity-result');
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildInfoFooter(),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Bản mẫu giao diện • Dữ liệu minh họa',
                        style: TextStyle(fontSize: 10, color: AppColors.greyText),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Row( 
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: AppColors.successBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/ic_sprout_smile.png',
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppColors.primary, size: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Mẹ Lan ơi, cùng bé An xem tháng vừa rồi nhà mình dùng bao nhiêu điện nhé!',
            style: TextStyle(fontSize: 13, color: AppColors.darkText, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập điện sử dụng tháng trước',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tháng ghi nhận',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/ic_calendar.png',
                  width: 20,
                  height: 20,
                  color: AppColors.primary,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Tháng 09/2026', style: TextStyle(fontSize: 14, color: AppColors.darkText)),
                ),
                Image.asset(
                  'assets/icons/ic_arrow_down.png',
                  width: 24,
                  height: 24,
                  color: AppColors.primary.withValues(alpha: 0.8),
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.keyboard_arrow_down, color: AppColors.primary.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Điện tiêu thụ (kWh)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _kwhController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const Text(
                  'kWh',
                  style: TextStyle(fontSize: 14, color: AppColors.subText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nhập số kWh, không nhập số tiền trên hóa đơn.',
            style: TextStyle(fontSize: 11, color: AppColors.subText),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blueBg,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tìm số ở đâu trên hóa đơn?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.bluePrimary),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mở hóa đơn điện và tìm dòng "Điện năng tiêu thụ" hoặc "Sản lượng".',
            style: TextStyle(fontSize: 13, color: AppColors.bluePrimary, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('HÓA ĐƠN ĐIỆN • VÍ DỤ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.greyText)),
                    Text('09/2026', style: TextStyle(fontSize: 10, color: AppColors.greyText)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Điện năng tiêu thụ', style: TextStyle(fontSize: 12, color: AppColors.darkText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blueBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '250 kWh',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.bluePrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/icons/ic_info.png',
                width: 16,
                height: 16,
                color: AppColors.subText,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.info_outline, size: 16, color: AppColors.subText),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cách tính: kWh × 0,6592 kg CO₂e/kWh. Hệ số minh họa — cần cập nhật theo nguồn công bố chính thức.',
                  style: TextStyle(fontSize: 11, color: AppColors.subText, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Ước tính từ điện sử dụng, không phải toàn bộ dấu chân carbon.',
            style: TextStyle(fontSize: 11, color: AppColors.subText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

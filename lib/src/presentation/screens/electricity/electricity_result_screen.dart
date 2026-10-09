import 'package:flutter/material.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class ElectricityResultScreen extends StatelessWidget {
  const ElectricityResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Dấu xanh của nhà',
              subtitle: 'Kết quả & lịch sử điện sử dụng',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResultCard(),
                    const SizedBox(height: 32),
                    _buildCalculationInfo(),
                    const SizedBox(height: 32),
                    _buildChartCard(),
                    const SizedBox(height: 24),
                    _buildTipCard(),
                    const SizedBox(height: 32),
                    const Text(
                      'Lịch sử ghi nhận',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 16),
                    _buildHistoryItem('09/2026', '250 kWh', '164,8 kg CO₂e'),
                    const SizedBox(height: 12),
                    _buildHistoryItem('08/2026', '280 kWh', '184,6 kg CO₂e'),
                    const SizedBox(height: 32),
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

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tháng 09/2026',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Image.asset(
                'assets/icons/ic_leaf_outline.png',
                width: 24,
                height: 24,
                color: AppColors.primary,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco_outlined, color: AppColors.primary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '164,8',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.0),
              ),
              SizedBox(width: 8),
              Text(
                'kg CO₂e',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Từ 250 kWh điện gia đình sử dụng',
            style: TextStyle(fontSize: 13, color: AppColors.darkText),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.arrow_downward, color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              const Text(
                'Giảm 19,8 kg CO₂e so với tháng 08',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mình tính như thế nào?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Text(
            '250 kWh × 0,6592 kg CO₂e/kWh = 164,8 kg CO₂e',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
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
                  'Hệ số minh họa — cần cập nhật theo nguồn công bố chính thức. Ước tính từ điện sử dụng, không phải toàn bộ dấu chân carbon.',
                  style: TextStyle(fontSize: 11, color: AppColors.subText, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    final List<Map<String, dynamic>> data = [
      {'label': 'T04', 'value': 204.4},
      {'label': 'T05', 'value': 194.5},
      {'label': 'T06', 'value': 184.6},
      {'label': 'T07', 'value': 174.7},
      {'label': 'T08', 'value': 184.6},
      {'label': 'T09', 'value': 164.8},
    ];

    double maxValue = 250.0; // Arbitrary max for scaling
    double chartHeight = 120.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '6 tháng của gia đình',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              Text(
                'kg CO₂e',
                style: TextStyle(fontSize: 10, color: AppColors.subText),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: chartHeight + 40, // space for labels
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final isLast = item == data.last;
                final barHeight = (item['value'] / maxValue) * chartHeight;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item['value'].toString().replaceAll('.', ','),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                        color: isLast ? AppColors.primary : AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isLast ? AppColors.primary : const Color(0xFFC5DFBD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['label'],
                      style: const TextStyle(fontSize: 10, color: AppColors.subText),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Dữ liệu giả định minh họa • Làm tròn 1 chữ số thập phân.',
            style: TextStyle(fontSize: 10, color: AppColors.subText),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blueBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/ic_sprout_smile.png',
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppColors.bluePrimary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Thử làm “thám tử tiết kiệm điện”!',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.bluePrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cùng con tìm đèn còn sáng khi phòng trống. Nhờ người lớn tắt thiết bị; bé không tự chạm ổ điện. Mỗi tối đánh dấu một việc đã làm.',
            style: TextStyle(fontSize: 13, color: AppColors.darkText, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String timeInfo, String electricityInfo, String resultInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$timeInfo • $electricityInfo',
            style: const TextStyle(fontSize: 13, color: AppColors.darkText),
          ),
          Text(
            resultInfo,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

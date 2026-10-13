import 'package:flutter/material.dart';
import '../../../widgets/custom_app_bar.dart';

// Màu riêng của màn này
const Color _kGreenLightE8EFE5 = Color(0xFFE8EFE5);

class HouseholdShimmerLoading extends StatelessWidget {
  const HouseholdShimmerLoading({super.key});

  Widget _buildPlaceholder({
    required double width,
    required double height,
    double borderRadius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _kGreenLightE8EFE5,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar(
          title: 'Gia đình',
          subtitle: 'Đang tải thông tin hộ gia đình...',
          showBackButton: false,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlaceholder(width: double.infinity, height: 90, borderRadius: 20),
                const SizedBox(height: 24),
                _buildPlaceholder(width: 140, height: 20, borderRadius: 6),
                const SizedBox(height: 12),
                _buildPlaceholder(width: double.infinity, height: 160, borderRadius: 20),
                const SizedBox(height: 20),
                _buildPlaceholder(width: double.infinity, height: 52, borderRadius: 16),
                const SizedBox(height: 14),
                _buildPlaceholder(width: double.infinity, height: 52, borderRadius: 16),
                const SizedBox(height: 14),
                _buildPlaceholder(width: double.infinity, height: 52, borderRadius: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

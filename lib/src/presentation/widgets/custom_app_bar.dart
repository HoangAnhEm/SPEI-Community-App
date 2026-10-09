import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          InkWell(
            onTap: onBack ?? () => context.pop(),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/ic_back.png',
                  width: 20,
                  height: 20,
                  color: AppColors.primary,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.subText),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/icons/logo.png',
            width: 44,
            height: 33,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

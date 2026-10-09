import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthHeader extends StatelessWidget {
  final bool showBackButton;
  final String? stepText;

  const AuthHeader({
    super.key,
    this.showBackButton = true,
    this.stepText,
  });

  @override
  Widget build(BuildContext context) {
    const darkTextColor = Color(0xFF1B3D2F);
    const subTextColor = Color(0xFF7B8780);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and Slogan
        Row(
          children: [
            Image.asset(
              'assets/icons/logo.png', // Thay thế bằng logo.png
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPEI Community',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                Text(
                  'GIEO MẦM SỐNG XANH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Back Button & Step Text
        if (showBackButton)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/ic_back.png',
                      width: 20,
                      height: 20,
                      color: const Color(0xFF3B7D53),
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.arrow_back, color: Color(0xFF3B7D53), size: 20), // Fallback tạm
                    ),
                  ),
                ),
              ),
              if (stepText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    stepText!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

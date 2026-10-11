import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = 'Hủy',
    required this.confirmText,
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = true,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'Hủy',
    required String confirmText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => CustomConfirmDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: () {
          Navigator.of(dialogContext).pop(true);
          onConfirm();
        },
        onCancel: () {
          Navigator.of(dialogContext).pop(false);
          onCancel?.call();
        },
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.subText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // Nút 1: Hủy (Nằm trên)
            InkWell(
              onTap: onCancel ?? () => Navigator.of(context).pop(false),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8DE)),
                ),
                child: Center(
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nút 2: Xác nhận (Nằm dưới - đỏ nếu isDestructive)
            InkWell(
              onTap: onConfirm,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: isDestructive ? const Color(0xFFFDE8E8) : AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    confirmText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDestructive ? const Color(0xFFC94A4A) : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

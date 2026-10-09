import 'package:flutter/material.dart';
import '../../../src/core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String? iconPath;
  final IconData? fallbackIcon;
  final bool isLoading;
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconPath,
    this.fallbackIcon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    const buttonColor = AppColors.primary;
    const disabledColor = Color(0xFFA5C3B1);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? disabledColor : buttonColor,
          disabledBackgroundColor: disabledColor,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconPath != null) ...[
                    Image.asset(
                      iconPath!,
                      width: 20,
                      height: 20,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) => fallbackIcon != null
                          ? Icon(fallbackIcon, color: Colors.white, size: 20)
                          : const SizedBox(width: 20, height: 20),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}



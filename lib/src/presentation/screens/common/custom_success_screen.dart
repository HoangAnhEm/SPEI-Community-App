import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';

class CustomSuccessArgs {
  final String? appBarTitle;
  final String? appBarSubtitle;
  final String title;
  final String? subtitle;
  final String? cardTag;
  final String? cardHighlightText;
  final String? cardDescription;
  final Widget? infoCard;
  final String buttonText;
  final IconData? buttonIcon;
  final String? buttonIconAsset;
  final VoidCallback? onButtonPressed;
  final void Function(BuildContext context)? onButtonPressedWithContext;
  final Widget? bottomWidget;
  final String? footerNote;

  const CustomSuccessArgs({
    this.appBarTitle,
    this.appBarSubtitle,
    required this.title,
    this.subtitle,
    this.cardTag,
    this.cardHighlightText,
    this.cardDescription,
    this.infoCard,
    required this.buttonText,
    this.buttonIcon,
    this.buttonIconAsset,
    this.onButtonPressed,
    this.onButtonPressedWithContext,
    this.bottomWidget,
    this.footerNote,
  });
}

/// Abstract, reusable success screen designed for multiple flows across the application.
/// Features ic_sprout_smile, shared custom app bar (no back button), customizable text and navigation callback.
class CustomSuccessScreen extends StatelessWidget {
  final String? appBarTitle;
  final String? appBarSubtitle;
  final String title;
  final String? subtitle;
  final String? cardTag;
  final String? cardHighlightText;
  final String? cardDescription;
  final Widget? infoCard;
  final String buttonText;
  final IconData? buttonIcon;
  final String? buttonIconAsset;
  final VoidCallback? onButtonPressed;
  final void Function(BuildContext context)? onButtonPressedWithContext;
  final Widget? bottomWidget;
  final String? footerNote;

  const CustomSuccessScreen({
    super.key,
    this.appBarTitle,
    this.appBarSubtitle,
    required this.title,
    this.subtitle,
    this.cardTag,
    this.cardHighlightText,
    this.cardDescription,
    this.infoCard,
    required this.buttonText,
    this.buttonIcon,
    this.buttonIconAsset,
    this.onButtonPressed,
    this.onButtonPressedWithContext,
    this.bottomWidget,
    this.footerNote,
  });

  factory CustomSuccessScreen.fromArgs({
    Key? key,
    required CustomSuccessArgs args,
  }) {
    return CustomSuccessScreen(
      key: key,
      appBarTitle: args.appBarTitle,
      appBarSubtitle: args.appBarSubtitle,
      title: args.title,
      subtitle: args.subtitle,
      cardTag: args.cardTag,
      cardHighlightText: args.cardHighlightText,
      cardDescription: args.cardDescription,
      infoCard: args.infoCard,
      buttonText: args.buttonText,
      buttonIcon: args.buttonIcon,
      buttonIconAsset: args.buttonIconAsset,
      onButtonPressed: args.onButtonPressed,
      onButtonPressedWithContext: args.onButtonPressedWithContext,
      bottomWidget: args.bottomWidget,
      footerNote: args.footerNote,
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                title: appBarTitle ?? 'SPEI Community',
                subtitle: appBarSubtitle ?? 'GIEO MẦM SỐNG XANH',
                showBackButton: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header title & subtitle in body
                      if (title.isNotEmpty) ...[
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.subText,
                              height: 1.45,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],

                      // Card Mầm xanh
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/icons/ic_sprout_smile.png',
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.eco, size: 60, color: AppColors.primary),
                            ),
                            if (cardTag != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                cardTag!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                            if (cardHighlightText != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                cardHighlightText!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ],
                            if (cardDescription != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                cardDescription!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.subText,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Card chi tiết mở rộng nếu có
                      if (infoCard != null) ...[
                        const SizedBox(height: 16),
                        infoCard!,
                      ],

                      // Nút hành động chính
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: buttonText,
                        iconPath: buttonIconAsset,
                        fallbackIcon: buttonIcon,
                        onPressed: () {
                          if (onButtonPressedWithContext != null) {
                            onButtonPressedWithContext!(context);
                          } else if (onButtonPressed != null) {
                            onButtonPressed!();
                          }
                        },
                      ),

                      // Widget mở rộng phía dưới nếu có (hình minh họa...)
                      if (bottomWidget != null) ...[
                        const SizedBox(height: 20),
                        bottomWidget!,
                      ],

                      // Footer note
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          footerNote ?? '',
                          style: const TextStyle(fontSize: 10, color: AppColors.greyText),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

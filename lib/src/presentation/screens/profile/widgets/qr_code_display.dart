import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class QrCodeDisplay extends StatelessWidget {
  final String data;
  final double size;
  final Color color;

  const QrCodeDisplay({
    super.key,
    required this.data,
    this.size = 200,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data.isNotEmpty ? data : 'spei_user_id',
      version: QrVersions.auto,
      size: size,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: color,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: color,
      ),
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }
}

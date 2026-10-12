import 'package:flutter/services.dart';

/// Dịch vụ tiện ích phát và xem minh chứng video/hình ảnh
class MediaService {
  static const MethodChannel _channel =
      MethodChannel('com.example.spei_community/media');

  /// Mở video bằng trình phát video hệ thống (Google Photos, Gallery Player,...)
  static Future<bool> openVideo(String path) async {
    try {
      final result =
          await _channel.invokeMethod<bool>('openVideo', {'path': path});
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}

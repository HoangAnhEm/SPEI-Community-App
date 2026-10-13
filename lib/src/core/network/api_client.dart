import 'package:dio/dio.dart';
import '../../data/datasources/local/local_data_source.dart';

class ApiClient {
  final Dio _dio;
  final LocalDataSource _localDataSource;
  final void Function()? onSessionExpired;

  ApiClient(this._localDataSource, {this.onSessionExpired}) : _dio = Dio() {
    // Port 8080 và có prefix /api/v1
    _dio.options.baseUrl = 'http://10.0.2.2:8080/api/v1'; // Default emulator
    // _dio.options.baseUrl = 'http://127.0.0.1:8080/api/v1'; // For iOS simulator
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _localDataSource.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Chỉ xử lý refresh token khi gặp lỗi 401 Unauthorized
        if (error.response?.statusCode == 401) {
          final path = error.requestOptions.path;
          
          // Bỏ qua các endpoint xác thực không cần refresh
          final isAuthEndpoint = path.contains('/auth/login') ||
              path.contains('/auth/register') ||
              path.contains('/auth/verify-otp') ||
              path.contains('/auth/forgot-password') ||
              path.contains('/auth/reset-password') ||
              path.contains('/auth/refresh') ||
              path.contains('/auth/otp/resend'); 
          if (isAuthEndpoint) {
            return handler.next(error);
          }

          final refreshToken = await _localDataSource.getRefreshToken();
          if (refreshToken == null || refreshToken.isEmpty) {
            // Không có refresh token -> Hết phiên làm việc
            await _handleSessionExpired();
            return handler.next(error);
          }

          try {
            // Sử dụng một Dio độc lập để gọi /auth/refresh nhằm tránh vòng lặp interceptor
            final refreshDio = Dio(BaseOptions(
              baseUrl: _dio.options.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

            final response = await refreshDio.post(
              '/auth/refresh',
              data: {'refresh_token': refreshToken},
            );

            final data = response.data['data'];
            final newAccessToken = data['access_token'] as String;
            final newRefreshToken = data['refresh_token'] as String;

            // Lưu cặp token mới (Backend áp dụng token rotation)
            await _localDataSource.saveToken(newAccessToken);
            await _localDataSource.saveRefreshToken(newRefreshToken);

            // Gán access token mới vào request bị lỗi và gửi lại (retry)
            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          } catch (refreshError) {
            // Refresh token cũng đã hết hạn hoặc bị thu hồi trên server
            await _handleSessionExpired();
            return handler.next(error);
          }
        }

        return handler.next(error);
      },
    ));
  }

  Future<void> _handleSessionExpired() async {
    await _localDataSource.clearToken();
    await _localDataSource.clearUser();
    onSessionExpired?.call();
  }

  Dio get dio => _dio;
}

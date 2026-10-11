import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/user.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Dio get _dio => _apiClient.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['data']; // { access_token, refresh_token }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Đăng nhập thất bại.');
    }
  }

  Future<User> getMyProfile(String token) async {
    try {
      final response = await _dio.get('/auth/me', 
        options: Options(headers: {'Authorization': 'Bearer $token'})
      );
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể lấy thông tin người dùng.');
    }
  }

  Future<void> registerInfo(String email, String phone, String fullName, String password) async {
    try {
      await _dio.post('/auth/register', data: {
        'email': email,
        'phone_number': phone,
        'full_name': fullName,
        'password': password,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Đăng ký thất bại.');
    }
  }

  Future<void> resendOtp(String email, String purpose) async {
    try {
      await _dio.post('/auth/otp/resend', data: {
        'email': email,
        'purpose': purpose
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể gửi lại OTP.');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp, String purpose) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp_code': otp,
        'purpose': purpose
      });
      // response.data['data'] includes 'tokens' and 'user'
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Mã OTP không hợp lệ.');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể gửi yêu cầu lấy lại mật khẩu.');
    }
  }

  Future<void> resetPassword(String newPassword) async {
    try {
      // NOTE: get_current_user require token in header. ApiClient interceptor has already added token if present in LocalDataSource.
      // So we just need to send new_password
      await _dio.post('/auth/reset-password', data: {
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể đặt lại mật khẩu.');
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      return response.data['data']; // { access_token, refresh_token, token_type, expires_in }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Phiên làm việc đã hết hạn.');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.post('/auth/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Đổi mật khẩu thất bại.');
    }
  }
}

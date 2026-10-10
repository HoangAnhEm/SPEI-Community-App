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
}

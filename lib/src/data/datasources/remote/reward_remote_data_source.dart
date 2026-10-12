import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class RewardRemoteDataSource {
  final ApiClient _apiClient;

  RewardRemoteDataSource(this._apiClient);

  Dio get _dio => _apiClient.dio;

  /// Lấy số dư ví điểm xanh hiện tại của người dùng đăng nhập (/api/v1/loyalty/balance)
  Future<Map<String, dynamic>> getBalance() async {
    try {
      final response = await _dio.get('/loyalty/balance');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.response?.data?['detail'] ??
            'Không thể tải số dư ví điểm xanh.',
      );
    }
  }

  /// Lấy danh sách quà đang mở bán (/api/v1/loyalty/rewards)
  Future<List<dynamic>> getRewards() async {
    try {
      final response = await _dio.get('/loyalty/rewards');
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.response?.data?['detail'] ??
            'Không thể tải danh sách quà tặng.',
      );
    }
  }

  /// Tiến hành đổi quà (/api/v1/loyalty/redeem)
  Future<Map<String, dynamic>> redeemReward(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/loyalty/redeem',
        data: data,
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.response?.data?['detail'] ??
            'Đổi quà thất bại. Vui lòng thử lại sau.',
      );
    }
  }
}

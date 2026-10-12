import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/emission_details.dart';

class EmissionRemoteDataSource {
  final ApiClient _apiClient;

  EmissionRemoteDataSource(this._apiClient);

  Dio get _dio => _apiClient.dio;

  /// Tính toán phát thải
  Future<Map<String, dynamic>> calculateEmission(CalculateEmissionRequest request) async {
    try {
      final response = await _dio.post(
        '/emission/calculate',
        data: request.toJson(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể tính toán phát thải.');
    }
  }

  /// Lấy danh sách phát thải tháng hiện tại của hộ
  Future<List<dynamic>> getHouseholdCurrentEmissions() async {
    try {
      final response = await _dio.get('/emission/household/current');
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể tải phát thải tháng hiện tại.');
    }
  }

  /// Lấy danh sách phát thải theo năm & tháng của hộ
  Future<List<dynamic>> getHouseholdEmissionsByPeriod({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.get(
        '/emission/household',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể tải phát thải theo kỳ.');
    }
  }

  /// Lấy lịch sử phát thải hộ gia đình
  Future<List<dynamic>> getHouseholdEmissionHistory({int limit = 12}) async {
    try {
      final response = await _dio.get(
        '/emission/household/history',
        queryParameters: {'limit': limit},
      );
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể tải lịch sử phát thải.');
    }
  }

  /// Ghi nhận phát thải tháng của hộ gia đình
  Future<Map<String, dynamic>> recordHouseholdEmission(
    RecordHouseholdEmissionRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/emission/household',
        data: request.toJson(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể ghi nhận phát thải hộ gia đình.');
    }
  }

  /// Chỉnh sửa bản ghi phát thải hộ gia đình
  Future<Map<String, dynamic>> updateHouseholdEmission({
    required String emissionId,
    required UpdateHouseholdEmissionRequest request,
  }) async {
    try {
      final response = await _dio.put(
        '/emission/household/$emissionId',
        data: request.toJson(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể cập nhật bản ghi phát thải.');
    }
  }

  /// Xóa bản ghi phát thải hộ gia đình
  Future<void> deleteHouseholdEmission(String emissionId) async {
    try {
      await _dio.delete('/emission/household/$emissionId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể xóa bản ghi phát thải.');
    }
  }
}

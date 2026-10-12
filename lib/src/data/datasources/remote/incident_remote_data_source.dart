import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class IncidentRemoteDataSource {
  final ApiClient _apiClient;

  IncidentRemoteDataSource(this._apiClient);

  Dio get _dio => _apiClient.dio;

  /// Lấy danh sách phản ánh (có lọc trạng thái: 'all', 'submitted', 'under_review', 'forwarded', 'in_progress', 'resolved', 'closed', 'rejected')
  Future<List<dynamic>> getIncidents({
    String status = 'all',
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/incidents',
        queryParameters: {
          'status': status,
          'limit': limit,
          'offset': offset,
        },
      );
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải danh sách phản ánh.',
      );
    }
  }

  /// Lấy danh sách phản ánh do chính người dùng hiện tại tạo
  Future<List<dynamic>> getMyIncidents() async {
    try {
      final response = await _dio.get('/incidents/me');
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Không thể tải danh sách phản ánh của bạn.',
      );
    }
  }

  /// Lấy thông tin chi tiết một phản ánh theo ID
  Future<Map<String, dynamic>> getIncidentById(String incidentId) async {
    try {
      final response = await _dio.get('/incidents/$incidentId');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải chi tiết phản ánh.',
      );
    }
  }

  /// Gửi phản ánh mới kèm tệp ảnh/video qua Multipart Form Data
  Future<Map<String, dynamic>> submitIncident(FormData formData) async {
    try {
      final response = await _dio.post(
        '/incidents',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể gửi phản ánh vi phạm.',
      );
    }
  }

  /// Gửi phản ánh mới bằng JSON payload (dùng URL ảnh có sẵn)
  Future<Map<String, dynamic>> submitIncidentJson(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '/incidents/json',
        data: data,
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể gửi phản ánh vi phạm.',
      );
    }
  }

  /// Tải lên một tệp chứng cứ cho phản ánh đã tồn tại
  Future<Map<String, dynamic>> uploadEvidence({
    required String incidentId,
    required MultipartFile file,
  }) async {
    try {
      final formData = FormData.fromMap({'file': file});
      final response = await _dio.post(
        '/incidents/$incidentId/evidence',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải lên tệp chứng cứ.',
      );
    }
  }

  /// Tải lên nhiều tệp chứng cứ cho phản ánh đã tồn tại
  Future<List<dynamic>> uploadMultipleEvidences({
    required String incidentId,
    required List<MultipartFile> files,
  }) async {
    try {
      final formData = FormData.fromMap({'files': files});
      final response = await _dio.post(
        '/incidents/$incidentId/evidences',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải lên danh sách chứng cứ.',
      );
    }
  }

  /// Cập nhật trạng thái phản ánh (Admin)
  Future<Map<String, dynamic>> updateIncidentStatus({
    required String incidentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.patch(
        '/incidents/$incidentId/status',
        data: data,
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Không thể cập nhật trạng thái phản ánh.',
      );
    }
  }
}

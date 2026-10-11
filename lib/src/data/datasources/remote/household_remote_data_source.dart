import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class HouseholdRemoteDataSource {
  final ApiClient _apiClient;

  HouseholdRemoteDataSource(this._apiClient);

  Dio get _dio => _apiClient.dio;

  // --- Quản lý hộ gia đình ---

  Future<Map<String, dynamic>?> getMyHousehold() async {
    try {
      final response = await _dio.get('/household/me');
      final data = response.data['data'];
      if (data == null) return null;
      return data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể tải thông tin hộ gia đình.');
    }
  }

  Future<Map<String, dynamic>> createHousehold(String name) async {
    try {
      final response = await _dio.post('/household', data: {'name': name});
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể tạo hộ gia đình.');
    }
  }

  Future<Map<String, dynamic>> updateHousehold(String name) async {
    try {
      final response = await _dio.patch('/household', data: {'name': name});
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể cập nhật hộ gia đình.');
    }
  }

  Future<Map<String, dynamic>> transferOwnership(String newOwnerId) async {
    try {
      final response = await _dio.post(
        '/household/transfer-ownership',
        data: {'new_owner_id': newOwnerId},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể chuyển quyền chủ hộ.');
    }
  }

  Future<void> deleteHousehold() async {
    try {
      await _dio.delete('/household');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể giải tán hộ gia đình.');
    }
  }

  Future<void> leaveHousehold() async {
    try {
      await _dio.post('/household/leave');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể rời hộ gia đình.');
    }
  }

  Future<void> removeMember(String targetUserId) async {
    try {
      await _dio.delete('/household/members/$targetUserId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể xóa thành viên khỏi hộ.');
    }
  }

  // --- Lời mời trực tiếp (Direct Invitations) ---

  Future<Map<String, dynamic>> lookupUser({
    String? userId,
    String? phoneNumber,
    String? email,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null && userId.trim().isNotEmpty) {
        queryParams['user_id'] = userId.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        queryParams['phone_number'] = phoneNumber.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        queryParams['email'] = email.trim();
      }
      final response = await _dio.get(
        '/household/invitations/lookup-user',
        queryParameters: queryParams,
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể tra cứu thông tin người dùng.');
    }
  }

  Future<Map<String, dynamic>> inviteDirect(String inviteeId) async {
    try {
      final response = await _dio.post(
        '/household/invitations/direct',
        data: {'invitee_id': inviteeId},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể gửi lời mời tham gia.');
    }
  }

  Future<List<dynamic>> getSentInvitations() async {
    try {
      final response = await _dio.get('/household/invitations/sent');
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể lấy danh sách lời mời đã gửi.');
    }
  }

  Future<List<dynamic>> getReceivedInvitations() async {
    try {
      final response = await _dio.get('/household/invitations/received');
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể lấy danh sách lời mời nhận được.');
    }
  }

  Future<Map<String, dynamic>> acceptInvitation(String invitationId) async {
    try {
      final response = await _dio.post('/household/invitations/$invitationId/accept');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể chấp nhận lời mời.');
    }
  }

  Future<void> rejectInvitation(String invitationId) async {
    try {
      await _dio.post('/household/invitations/$invitationId/reject');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể từ chối lời mời.');
    }
  }

  Future<void> revokeInvitation(String invitationId) async {
    try {
      await _dio.delete('/household/invitations/$invitationId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể thu hồi lời mời.');
    }
  }

  // --- Yêu cầu gia nhập (Join Requests) ---

  Future<Map<String, dynamic>> lookupHousehold(String householdId) async {
    try {
      final response = await _dio.get(
        '/household/lookup',
        queryParameters: {'household_id': householdId},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể tra cứu thông tin hộ gia đình.');
    }
  }

  Future<Map<String, dynamic>> createJoinRequest(String householdId) async {
    try {
      final response = await _dio.post(
        '/household/join-requests',
        data: {'household_id': householdId},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể gửi yêu cầu xin gia nhập.');
    }
  }

  Future<List<dynamic>> getMyJoinRequests() async {
    try {
      final response = await _dio.get('/household/join-requests/my-requests');
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể lấy danh sách yêu cầu đã gửi.');
    }
  }

  Future<void> cancelMyJoinRequest(String requestId) async {
    try {
      await _dio.delete('/household/join-requests/$requestId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể hủy yêu cầu gia nhập.');
    }
  }

  Future<List<dynamic>> getHouseholdJoinRequests() async {
    try {
      final response = await _dio.get('/household/join-requests');
      return (response.data['data'] as List<dynamic>?) ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể lấy danh sách yêu cầu gia nhập.');
    }
  }

  Future<Map<String, dynamic>> approveJoinRequest(String requestId) async {
    try {
      final response = await _dio.post('/household/join-requests/$requestId/approve');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể duyệt yêu cầu gia nhập.');
    }
  }

  Future<void> rejectJoinRequest(String requestId) async {
    try {
      await _dio.post('/household/join-requests/$requestId/reject');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể từ chối yêu cầu gia nhập.');
    }
  }
}

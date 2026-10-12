import '../entities/incident.dart';
import '../../data/models/incident_model.dart';

abstract class IncidentRepository {
  /// Lấy danh sách phản ánh (tất cả hoặc theo trạng thái)
  Future<List<Incident>> getIncidents({
    String status = 'all',
    int limit = 50,
    int offset = 0,
  });

  /// Lấy danh sách phản ánh do chính người dùng hiện tại gửi
  Future<List<Incident>> getMyIncidents();

  /// Lấy chi tiết một phản ánh theo ID
  Future<Incident> getIncidentById(String incidentId);

  /// Gửi phản ánh vi phạm môi trường mới (hỗ trợ tệp đính kèm hoặc URL)
  Future<Incident> submitIncident(CreateIncidentRequest request);

  /// Tải lên một tệp chứng cứ bổ sung cho phản ánh
  Future<IncidentEvidence> uploadEvidence({
    required String incidentId,
    required String filePath,
  });

  /// Tải lên danh sách các tệp chứng cứ bổ sung cho phản ánh
  Future<List<IncidentEvidence>> uploadMultipleEvidences({
    required String incidentId,
    required List<String> filePaths,
  });

  /// Cập nhật trạng thái phản ánh (Admin / QTV)
  Future<Incident> updateIncidentStatus({
    required String incidentId,
    required UpdateIncidentStatusRequest request,
  });
}

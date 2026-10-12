import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/entities/incident.dart';

/// Request DTO để gửi phản ánh vi phạm môi trường
class CreateIncidentRequest {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime occurredAt;
  final List<String> filePaths;
  final List<String> evidenceUrls;

  const CreateIncidentRequest({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.occurredAt,
    this.filePaths = const [],
    this.evidenceUrls = const [],
  });

  /// Chuyển thành JSON payload khi gửi qua /incidents/json
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'occurred_at': occurredAt.toUtc().toIso8601String(),
      'evidence_urls': evidenceUrls,
    };
  }

  /// Chuyển thành FormData multipart khi gửi qua /incidents kèm tệp
  Future<FormData> toFormData() async {
    final formMap = <String, dynamic>{
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'occurred_at': occurredAt.toUtc().toIso8601String(),
    };

    final multipartFiles = <MultipartFile>[];
    for (final path in filePaths) {
      if (path.isEmpty) continue;
      final file = File(path);
      if (await file.exists()) {
        final filename = path.split(Platform.pathSeparator).last;
        multipartFiles.add(
          await MultipartFile.fromFile(
            path,
            filename: filename,
          ),
        );
      }
    }

    formMap['files'] = multipartFiles;
    return FormData.fromMap(formMap);
  }
}

/// Request DTO để cập nhật trạng thái phản ánh
class UpdateIncidentStatusRequest {
  final IncidentStatus status;
  final String? adminNotes;

  const UpdateIncidentStatusRequest({
    required this.status,
    this.adminNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
      if (adminNotes != null) 'admin_notes': adminNotes,
    };
  }
}

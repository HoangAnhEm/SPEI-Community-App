enum IncidentStatus {
  pending('pending', 'Chờ tiếp nhận'),
  investigating('investigating', 'Đang xác minh'),
  resolved('resolved', 'Đã xử lý'),
  rejected('rejected', 'Đã từ chối');

  final String value;
  final String label;

  const IncidentStatus(this.value, this.label);

  static IncidentStatus fromString(String? value) {
    if (value == null) return IncidentStatus.pending;
    return IncidentStatus.values.firstWhere(
      (s) => s.value.toLowerCase() == value.toLowerCase(),
      orElse: () => IncidentStatus.pending,
    );
  }

  bool get isPending => this == IncidentStatus.pending;
  bool get isInvestigating => this == IncidentStatus.investigating;
  bool get isResolved => this == IncidentStatus.resolved;
  bool get isRejected => this == IncidentStatus.rejected;
}

/// Thông tin tệp chứng cứ đính kèm phản ánh (ảnh/video)
class IncidentEvidence {
  final String id;
  final String fileUrl;
  final String mediaType; // "image" | "video"
  final int fileSizeBytes;
  final DateTime createdAt;

  const IncidentEvidence({
    required this.id,
    required this.fileUrl,
    this.mediaType = 'image',
    required this.fileSizeBytes,
    required this.createdAt,
  });

  bool get isImage => mediaType.toLowerCase() == 'image';
  bool get isVideo => mediaType.toLowerCase() == 'video';

  String get formattedFileSize {
    if (fileSizeBytes <= 0) return '';
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory IncidentEvidence.fromJson(Map<String, dynamic> json) {
    return IncidentEvidence(
      id: json['id'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? 'image',
      fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_url': fileUrl,
      'media_type': mediaType,
      'file_size_bytes': fileSizeBytes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  IncidentEvidence copyWith({
    String? id,
    String? fileUrl,
    String? mediaType,
    int? fileSizeBytes,
    DateTime? createdAt,
  }) {
    return IncidentEvidence(
      id: id ?? this.id,
      fileUrl: fileUrl ?? this.fileUrl,
      mediaType: mediaType ?? this.mediaType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Bản ghi khiếu nại / phản ánh vi phạm môi trường
class Incident {
  final String id;
  final String reportCode;
  final String reporterId;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime occurredAt;
  final IncidentStatus status;
  final String? adminNotes;
  final DateTime createdAt;
  final List<IncidentEvidence> evidences;

  const Incident({
    required this.id,
    required this.reportCode,
    required this.reporterId,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.occurredAt,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.evidences = const [],
  });

  String get statusLabel => status.label;

  /// Đường dẫn hình ảnh đầu tiên để hiển thị thumbnail nếu có
  String? get primaryImageUrl {
    for (final ev in evidences) {
      if (ev.isImage && ev.fileUrl.isNotEmpty) {
        return ev.fileUrl;
      }
    }
    return evidences.isNotEmpty ? evidences.first.fileUrl : null;
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    final evidencesJson = json['evidences'] as List<dynamic>?;
    final parsedEvidences = evidencesJson != null
        ? evidencesJson
            .map((e) => IncidentEvidence.fromJson(e as Map<String, dynamic>))
            .toList()
        : <IncidentEvidence>[];

    return Incident(
      id: json['id'] as String? ?? '',
      reportCode: json['report_code'] as String? ?? '',
      reporterId: json['reporter_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      occurredAt: DateTime.tryParse(json['occurred_at'] as String? ?? '') ??
          DateTime.now(),
      status: IncidentStatus.fromString(json['status'] as String?),
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      evidences: parsedEvidences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_code': reportCode,
      'reporter_id': reporterId,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'occurred_at': occurredAt.toIso8601String(),
      'status': status.value,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'evidences': evidences.map((e) => e.toJson()).toList(),
    };
  }

  Incident copyWith({
    String? id,
    String? reportCode,
    String? reporterId,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    DateTime? occurredAt,
    IncidentStatus? status,
    String? adminNotes,
    DateTime? createdAt,
    List<IncidentEvidence>? evidences,
  }) {
    return Incident(
      id: id ?? this.id,
      reportCode: reportCode ?? this.reportCode,
      reporterId: reporterId ?? this.reporterId,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      occurredAt: occurredAt ?? this.occurredAt,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      evidences: evidences ?? this.evidences,
    );
  }
}

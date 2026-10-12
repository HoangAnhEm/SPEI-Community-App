/// 7 trạng thái vòng đời của phản ánh vi phạm môi trường theo chuẩn Backend
enum IncidentStatus {
  submitted('submitted', 'Đã gửi'),
  underReview('under_review', 'Đang kiểm tra'),
  forwarded('forwarded', 'Đã chuyển cơ quan chức năng'),
  inProgress('in_progress', 'Đang xử lý'),
  resolved('resolved', 'Đã giải quyết'),
  closed('closed', 'Đóng hồ sơ'),
  rejected('rejected', 'Từ chối');

  final String value;
  final String label;

  const IncidentStatus(this.value, this.label);

  static IncidentStatus fromString(String? value) {
    if (value == null) return IncidentStatus.submitted;
    final lower = value.toLowerCase();
    // Tương thích ngược nếu còn sót dữ liệu cũ từ cache
    if (lower == 'pending') return IncidentStatus.submitted;
    if (lower == 'investigating') return IncidentStatus.inProgress;

    return IncidentStatus.values.firstWhere(
      (s) => s.value.toLowerCase() == lower,
      orElse: () => IncidentStatus.submitted,
    );
  }

  bool get isSubmitted => this == IncidentStatus.submitted;
  bool get isUnderReview => this == IncidentStatus.underReview;
  bool get isForwarded => this == IncidentStatus.forwarded;
  bool get isInProgress => this == IncidentStatus.inProgress;
  bool get isResolved => this == IncidentStatus.resolved;
  bool get isClosed => this == IncidentStatus.closed;
  bool get isRejected => this == IncidentStatus.rejected;

  /// Thứ tự bước trong quy trình milestone (1 đến 5; -1 cho từ chối)
  int get defaultStep {
    switch (this) {
      case IncidentStatus.submitted:
        return 1;
      case IncidentStatus.underReview:
        return 2;
      case IncidentStatus.forwarded:
        return 3;
      case IncidentStatus.inProgress:
        return 4;
      case IncidentStatus.resolved:
      case IncidentStatus.closed:
        return 5;
      case IncidentStatus.rejected:
        return -1;
    }
  }
}

/// Bước tiến trình trong vòng đời xử lý phản ánh (đồng bộ từ Backend IncidentLifecycleStep)
class IncidentLifecycleStep {
  final int step;
  final String code;
  final String label;
  final bool isCurrent;
  final bool isCompleted;

  const IncidentLifecycleStep({
    required this.step,
    required this.code,
    required this.label,
    required this.isCurrent,
    required this.isCompleted,
  });

  factory IncidentLifecycleStep.fromJson(Map<String, dynamic> json) {
    return IncidentLifecycleStep(
      step: json['step'] as int? ?? 1,
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      isCurrent: json['is_current'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'code': code,
      'label': label,
      'is_current': isCurrent,
      'is_completed': isCompleted,
    };
  }
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
  final String? statusLabelRaw;
  final int? currentStep;
  final List<IncidentLifecycleStep> lifecycleStepper;
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
    this.statusLabelRaw,
    this.currentStep,
    this.lifecycleStepper = const [],
    this.adminNotes,
    required this.createdAt,
    this.evidences = const [],
  });

  /// Nhãn hiển thị trạng thái (ưu tiên nhãn từ Backend gửi về)
  String get statusLabel =>
      (statusLabelRaw != null && statusLabelRaw!.isNotEmpty)
          ? statusLabelRaw!
          : status.label;

  /// Bước hiện tại trong quy trình
  int get step => currentStep ?? status.defaultStep;

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

    final stepperJson = json['lifecycle_stepper'] as List<dynamic>?;
    final parsedStepper = stepperJson != null
        ? stepperJson
            .map((e) =>
                IncidentLifecycleStep.fromJson(e as Map<String, dynamic>))
            .toList()
        : <IncidentLifecycleStep>[];

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
      statusLabelRaw: json['status_label'] as String?,
      currentStep: json['current_step'] as int?,
      lifecycleStepper: parsedStepper,
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
      'status_label': statusLabel,
      if (currentStep != null) 'current_step': currentStep,
      'lifecycle_stepper': lifecycleStepper.map((e) => e.toJson()).toList(),
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
    String? statusLabelRaw,
    int? currentStep,
    List<IncidentLifecycleStep>? lifecycleStepper,
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
      statusLabelRaw: statusLabelRaw ?? this.statusLabelRaw,
      currentStep: currentStep ?? this.currentStep,
      lifecycleStepper: lifecycleStepper ?? this.lifecycleStepper,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      evidences: evidences ?? this.evidences,
    );
  }
}

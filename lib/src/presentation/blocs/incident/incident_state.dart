import 'package:equatable/equatable.dart';
import '../../../domain/entities/incident.dart';

enum IncidentListStatus { initial, loading, loaded, error }

class IncidentState extends Equatable {
  final IncidentListStatus status;
  final List<Incident> incidents;
  final String selectedFilter; // 'all' | 'pending' | 'investigating' | 'resolved' | 'rejected'
  final String? errorMessage;
  final bool isSubmitting;
  final String? submitErrorMessage;
  final Incident? selectedIncident;

  const IncidentState({
    this.status = IncidentListStatus.initial,
    this.incidents = const [],
    this.selectedFilter = 'all',
    this.errorMessage,
    this.isSubmitting = false,
    this.submitErrorMessage,
    this.selectedIncident,
  });

  /// Danh sách phản ánh đã lọc theo tab được chọn
  List<Incident> get filteredIncidents {
    if (selectedFilter == 'all') return incidents;
    return incidents.where((item) => item.status.value == selectedFilter).toList();
  }

  int get countAll => incidents.length;
  int get countPending => incidents.where((i) => i.status.isPending).length;
  int get countInvestigating => incidents.where((i) => i.status.isInvestigating).length;
  int get countResolved => incidents.where((i) => i.status.isResolved).length;
  int get countRejected => incidents.where((i) => i.status.isRejected).length;

  IncidentState copyWith({
    IncidentListStatus? status,
    List<Incident>? incidents,
    String? selectedFilter,
    String? errorMessage,
    bool? isSubmitting,
    String? submitErrorMessage,
    Incident? selectedIncident,
  }) {
    return IncidentState(
      status: status ?? this.status,
      incidents: incidents ?? this.incidents,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitErrorMessage: submitErrorMessage,
      selectedIncident: selectedIncident ?? this.selectedIncident,
    );
  }

  @override
  List<Object?> get props => [
        status,
        incidents,
        selectedFilter,
        errorMessage,
        isSubmitting,
        submitErrorMessage,
        selectedIncident,
      ];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/incident_model.dart';
import '../../../domain/entities/incident.dart';
import '../../../domain/repositories/incident_repository.dart';
import 'incident_state.dart';

class IncidentCubit extends Cubit<IncidentState> {
  final IncidentRepository _repository;

  IncidentCubit(this._repository) : super(const IncidentState());

  /// Tải danh sách phản ánh do chính tài khoản người dùng gửi
  Future<void> loadMyIncidents({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: IncidentListStatus.loading));
    }
    try {
      final list = await _repository.getMyIncidents();
      emit(state.copyWith(
        status: IncidentListStatus.loaded,
        incidents: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: IncidentListStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Thay đổi tab lọc trạng thái
  void setFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  /// Chọn một incident để xem chi tiết
  void selectIncident(Incident incident) {
    emit(state.copyWith(selectedIncident: incident));
  }

  /// Tải chi tiết một phản ánh theo ID
  Future<Incident?> loadIncidentDetail(String id) async {
    try {
      final incident = await _repository.getIncidentById(id);
      final updatedList = state.incidents.map((i) {
        return i.id == id ? incident : i;
      }).toList();

      emit(state.copyWith(
        selectedIncident: incident,
        incidents: updatedList,
      ));
      return incident;
    } catch (_) {
      return null;
    }
  }

  /// Gửi phản ánh vi phạm mới
  Future<bool> submitIncident(CreateIncidentRequest request) async {
    emit(state.copyWith(isSubmitting: true, submitErrorMessage: null));
    try {
      final newIncident = await _repository.submitIncident(request);
      final updatedList = [newIncident, ...state.incidents];
      emit(state.copyWith(
        isSubmitting: false,
        incidents: updatedList,
        selectedIncident: newIncident,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        submitErrorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Bổ sung minh chứng cho phản ánh đã tồn tại
  Future<bool> addEvidence({
    required String incidentId,
    required List<String> filePaths,
  }) async {
    if (filePaths.isEmpty) return true;
    emit(state.copyWith(isSubmitting: true, submitErrorMessage: null));
    try {
      if (filePaths.length == 1) {
        await _repository.uploadEvidence(
          incidentId: incidentId,
          filePath: filePaths.first,
        );
      } else {
        await _repository.uploadMultipleEvidences(
          incidentId: incidentId,
          filePaths: filePaths,
        );
      }

      // Tải lại chi tiết bản ghi
      await loadIncidentDetail(incidentId);
      emit(state.copyWith(isSubmitting: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        submitErrorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }
}

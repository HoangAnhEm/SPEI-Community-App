import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

import '../../../config/di/di.dart';
import '../chat/chat_cubit.dart';
import '../emission/emission_cubit.dart';
import '../household/household_cubit.dart';
import '../incident/incident_cubit.dart';
import '../reward/reward_cubit.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
  }

  // ---------- helpers ----------

  /// Reset toàn bộ dữ liệu người dùng trên tất cả các cubit
  void _resetAllCubits() {
    getIt<HouseholdCubit>().reset();
    getIt<EmissionCubit>().reset();
    getIt<RewardCubit>().reset();
    getIt<IncidentCubit>().reset();
    getIt<ChatCubit>().reset();
  }

  /// Reload dữ liệu cho user vừa đăng nhập
  void _reloadForUser(String userId) {
    getIt<HouseholdCubit>().loadHouseholdData(userId: userId);
    getIt<RewardCubit>().loadRewardData();
    getIt<IncidentCubit>().loadMyIncidents();
    // EmissionCubit được HouseholdCubit kích hoạt sau khi tải xong hộ gia đình
  }

  // ---------- handlers ----------

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final isFirstTime = await _authRepository.isFirstTime();
    if (isFirstTime) {
      emit(AuthFirstTime());
      return;
    }

    final user = await _authRepository.checkAuthStatus();
    if (user != null) {
      emit(AuthAuthenticated(user));
      _reloadForUser(user.id);
    } else {
      emit(AuthUnauthenticated());
      _resetAllCubits();
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    _resetAllCubits();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthStatusChanged(
      AuthStatusChanged event, Emitter<AuthState> emit) async {
    // Được gọi sau khi login/register thành công để cập nhật lại state toàn cục
    final user = await _authRepository.checkAuthStatus();
    if (user != null) {
      // Reset trước để tránh dữ liệu cũ lẫn vào khi đổi tài khoản
      _resetAllCubits();
      emit(AuthAuthenticated(user));
      _reloadForUser(user.id);
    } else {
      emit(AuthUnauthenticated());
      _resetAllCubits();
    }
  }
}

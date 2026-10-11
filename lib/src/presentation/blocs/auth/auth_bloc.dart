import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

import '../../../config/di/di.dart';
import '../household/household_cubit.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final isFirstTime = await _authRepository.isFirstTime();
    if (isFirstTime) {
      emit(AuthFirstTime());
      return;
    }

    final user = await _authRepository.checkAuthStatus();
    if (user != null) {
      emit(AuthAuthenticated(user));
      getIt<HouseholdCubit>().loadHouseholdData(userId: user.id);
    } else {
      emit(AuthUnauthenticated());
      getIt<HouseholdCubit>().reset();
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    getIt<HouseholdCubit>().reset();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) async {
    // Được gọi khi user login/register thành công để cập nhật lại state toàn cục
    final user = await _authRepository.checkAuthStatus();
    if (user != null) {
      emit(AuthAuthenticated(user));
      getIt<HouseholdCubit>().loadHouseholdData(userId: user.id);
    } else {
      emit(AuthUnauthenticated());
      getIt<HouseholdCubit>().reset();
    }
  }
}

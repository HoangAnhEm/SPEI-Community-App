import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final AuthRepository _authRepository;

  ChangePasswordCubit(this._authRepository) : super(ChangePasswordInitial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty) {
      emit(ChangePasswordFailure('Vui lòng nhập mật khẩu hiện tại.'));
      return;
    }
    if (newPassword.isEmpty) {
      emit(ChangePasswordFailure('Vui lòng nhập mật khẩu mới.'));
      return;
    }
    if (newPassword.length < 8) {
      emit(ChangePasswordFailure('Mật khẩu mới phải có ít nhất 8 ký tự.'));
      return;
    }

    emit(ChangePasswordLoading());
    try {
      await _authRepository.changePassword(currentPassword, newPassword);
      emit(ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

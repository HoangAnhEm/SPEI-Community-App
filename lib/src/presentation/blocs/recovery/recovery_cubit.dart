import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'recovery_state.dart';

class RecoveryCubit extends Cubit<RecoveryState> {
  final AuthRepository _authRepository;

  String? currentEmail;

  RecoveryCubit(this._authRepository) : super(RecoveryInitial());

  Future<void> requestRecoveryOtp(String email) async {
    if (email.isEmpty) {
      emit(RecoveryFailure('Vui lòng nhập email.'));
      return;
    }
    
    emit(RecoveryLoading());
    try {
      await _authRepository.forgotPassword(email);
      currentEmail = email;
      emit(RecoveryOtpRequested());
    } catch (e) {
      emit(RecoveryFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (currentEmail == null) {
      emit(RecoveryFailure('Không tìm thấy thông tin email.'));
      return;
    }
    if (otp.length != 6) {
      emit(RecoveryFailure('Mã OTP phải gồm 6 chữ số.'));
      return;
    }

    emit(RecoveryLoading());
    try {
      final user = await _authRepository.verifyOtp(currentEmail!, otp, 'password_reset');
      // Token is automatically saved in repository, so we are authenticated.
      emit(RecoveryOtpVerified(user));
    } catch (e) {
      emit(RecoveryFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> resendOtp() async {
    if (currentEmail == null) {
      emit(RecoveryFailure('Không tìm thấy thông tin email.'));
      return;
    }

    emit(RecoveryLoading());
    try {
      await _authRepository.resendOtp(currentEmail!, 'password_reset');
      emit(RecoveryResendSuccess());
    } catch (e) {
      emit(RecoveryFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> resetPassword(String newPassword) async {
    if (newPassword.isEmpty) {
      emit(RecoveryFailure('Vui lòng nhập mật khẩu mới.'));
      return;
    }

    emit(RecoveryLoading());
    try {
      await _authRepository.resetPassword(newPassword);
      emit(RecoverySuccess());
    } catch (e) {
      emit(RecoveryFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

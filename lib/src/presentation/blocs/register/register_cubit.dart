import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  // Lưu tạm phone và email để dùng ở màn OTP và Success
  String? currentPhone;
  String? currentEmail;
  User? registeredUser; // Lưu kết quả sau khi Verify OTP thành công

  RegisterCubit(this._authRepository) : super(RegisterInitial());

  Future<void> submitInfo(String email, String phone, String fullName, String password) async {
    if (email.isEmpty || phone.isEmpty || fullName.isEmpty || password.isEmpty) {
      emit(RegisterFailure('Vui lòng nhập đầy đủ thông tin.'));
      return;
    }
    
    emit(RegisterLoading());
    try {
      await _authRepository.registerInfo(email, phone, fullName, password);
      currentPhone = phone;
      currentEmail = email;
      emit(RegisterInfoSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (currentEmail == null) {
      emit(RegisterFailure('Không tìm thấy thông tin email.'));
      return;
    }
    if (otp.length != 6) {
      emit(RegisterFailure('Mã OTP phải gồm 6 chữ số.'));
      return;
    }

    emit(RegisterLoading());
    try {
      final user = await _authRepository.verifyOtp(currentEmail!, otp, 'register');
      registeredUser = user;
      emit(RegisterOtpSuccess(user));
    } catch (e) {
      emit(RegisterFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> resendOtp() async {
    if (currentEmail == null) {
      emit(RegisterFailure('Không tìm thấy thông tin email.'));
      return;
    }

    emit(RegisterLoading());
    try {
      await _authRepository.resendOtp(currentEmail!, 'register');
      emit(RegisterResendSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

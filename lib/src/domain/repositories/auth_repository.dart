import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<void> registerInfo(String email, String phone, String password);
  Future<void> resendOtp(String phone);
  Future<User> verifyOtp(String phone, String otp);
  Future<void> logout();
  Future<User?> checkAuthStatus();
}

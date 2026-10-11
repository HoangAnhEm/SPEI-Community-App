import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> registerInfo(String email, String phone, String fullName, String password);
  Future<void> resendOtp(String email, String purpose);
  Future<User> verifyOtp(String email, String otp, String purpose);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String newPassword);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> logout();
  Future<User?> checkAuthStatus();
  Future<bool> isFirstTime();
  Future<void> setFirstTime(bool isFirstTime);
}

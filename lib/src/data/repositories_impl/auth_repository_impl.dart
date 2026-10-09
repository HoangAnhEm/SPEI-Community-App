import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockAuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login(String username, String password) {
    return remoteDataSource.login(username, password);
  }

  @override
  Future<void> registerInfo(String email, String phone, String password) {
    return remoteDataSource.registerInfo(email, phone, password);
  }

  @override
  Future<void> resendOtp(String phone) {
    return remoteDataSource.resendOtp(phone);
  }

  @override
  Future<User> verifyOtp(String phone, String otp) {
    return remoteDataSource.verifyOtp(phone, otp);
  }

  @override
  Future<void> logout() async {
    // TODO: Implement logic xóa token local
  }

  @override
  Future<User?> checkAuthStatus() {
    return remoteDataSource.checkAuthStatus();
  }
}

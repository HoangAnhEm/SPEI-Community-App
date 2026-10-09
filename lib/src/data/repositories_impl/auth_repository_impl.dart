import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_auth_remote_data_source.dart';
import '../datasources/local/local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockAuthRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String username, String password) async {
    final user = await remoteDataSource.login(username, password);
    await localDataSource.saveUser(user);
    await localDataSource.saveToken('mock_token_${user.id}'); // Giả lập lưu token
    return user;
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
  Future<User> verifyOtp(String phone, String otp) async {
    final user = await remoteDataSource.verifyOtp(phone, otp);
    await localDataSource.saveUser(user);
    await localDataSource.saveToken('mock_token_${user.id}');
    return user;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUser();
    await localDataSource.clearToken();
  }

  @override
  Future<User?> checkAuthStatus() async {
    // Ưu tiên kiểm tra local trước
    final user = await localDataSource.getUser();
    if (user != null) {
      return user;
    }
    // Nếu không có, có thể kiểm tra remote (nếu cần đổi token vv)
    return remoteDataSource.checkAuthStatus();
  }

  @override
  Future<bool> isFirstTime() {
    return localDataSource.isFirstTimeOpen();
  }

  @override
  Future<void> setFirstTime(bool isFirstTime) {
    return localDataSource.setFirstTimeOpen(isFirstTime);
  }
}

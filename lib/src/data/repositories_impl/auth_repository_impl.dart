import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../datasources/local/local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String email, String password) async {
    final tokens = await remoteDataSource.login(email, password);
    final accessToken = tokens['access_token'] as String;
    final refreshToken = tokens['refresh_token'] as String?;
    
    // Lưu token ngay để các api gọi sau có header
    await localDataSource.saveToken(accessToken); 
    if (refreshToken != null) {
      await localDataSource.saveRefreshToken(refreshToken);
    }

    // Lấy thông tin user
    final user = await remoteDataSource.getMyProfile(accessToken);
    await localDataSource.saveUser(user);
    
    return user;
  }

  @override
  Future<void> registerInfo(String email, String phone, String fullName, String password) {
    return remoteDataSource.registerInfo(email, phone, fullName, password);
  }

  @override
  Future<void> resendOtp(String email, String purpose) {
    return remoteDataSource.resendOtp(email, purpose);
  }

  @override
  Future<User> verifyOtp(String email, String otp, String purpose) async {
    final data = await remoteDataSource.verifyOtp(email, otp, purpose);
    
    final accessToken = data['tokens']?['access_token'] as String?;
    final refreshToken = data['tokens']?['refresh_token'] as String?;
    if (accessToken != null) {
      await localDataSource.saveToken(accessToken);
    }
    if (refreshToken != null) {
      await localDataSource.saveRefreshToken(refreshToken);
    }
    
    final user = User.fromJson(data['user']);
    await localDataSource.saveUser(user);
    
    return user;
  }

  @override
  Future<void> forgotPassword(String email) {
    return remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(String newPassword) {
    return remoteDataSource.resetPassword(newPassword);
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUser();
    await localDataSource.clearToken();
  }

  @override
  Future<User?> checkAuthStatus() async {
    final user = await localDataSource.getUser();
    if (user != null) {
      return user;
    }
    // Nếu có token nhưng chưa có user (có thể do clear cache), lấy lại user profile
    final token = await localDataSource.getToken();
    if (token != null) {
      try {
        final profile = await remoteDataSource.getMyProfile(token);
        await localDataSource.saveUser(profile);
        return profile;
      } catch (_) {
        return null;
      }
    }
    return null;
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

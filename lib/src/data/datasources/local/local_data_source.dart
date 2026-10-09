import '../../../domain/entities/user.dart';

abstract class LocalDataSource {
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> clearUser();

  Future<void> setFirstTimeOpen(bool isFirstTime);
  Future<bool> isFirstTimeOpen();

  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

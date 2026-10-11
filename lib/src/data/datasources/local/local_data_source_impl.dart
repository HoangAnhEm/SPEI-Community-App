import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../domain/entities/user.dart';
import 'local_data_source.dart';

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  LocalDataSourceImpl(this._prefs, this._secureStorage);

  static const String _keyUser = 'cached_user';
  static const String _keyFirstTime = 'is_first_time';
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';

  @override
  Future<void> saveUser(User user) async {
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  @override
  Future<User?> getUser() async {
    final userJson = _prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await _prefs.remove(_keyUser);
  }

  @override
  Future<void> setFirstTimeOpen(bool isFirstTime) async {
    await _prefs.setBool(_keyFirstTime, isFirstTime);
  }

  @override
  Future<bool> isFirstTimeOpen() async {
    // Nếu chưa từng lưu thì mặc định là true (mở lần đầu)
    return _prefs.getBool(_keyFirstTime) ?? true;
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  @override
  Future<void> clearToken() async {
    await _secureStorage.delete(key: _keyToken);
    await _secureStorage.delete(key: _keyRefreshToken);
  }
}

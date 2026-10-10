import 'package:dio/dio.dart';
import '../../data/datasources/local/local_data_source.dart';

class ApiClient {
  final Dio _dio;
  final LocalDataSource _localDataSource;

  ApiClient(this._localDataSource) : _dio = Dio() {
    // Port 8080 và có prefix /api/v1
    _dio.options.baseUrl = 'http://10.0.2.2:8080/api/v1'; // Default emulator
    // _dio.options.baseUrl = 'http://127.0.0.1:8080/api/v1'; // For iOS simulator
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _localDataSource.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Có thể thêm logic refresh token nếu 401 ở đây sau này
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}

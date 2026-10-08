import 'package:dio/dio.dart';

class DioClient {
  late Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com', // Thay bằng baseUrl thực tế
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    // Thêm AuthInterceptor nếu cần ở đây
  }
}

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<Dio>(() => DioClient().dio);

  // Data sources
  
  // Repositories
  
  // Use cases
  
  // Blocs
}

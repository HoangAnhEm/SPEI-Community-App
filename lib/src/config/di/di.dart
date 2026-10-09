import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/mock_auth_remote_data_source.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/blocs/login/login_cubit.dart';
import '../../presentation/blocs/register/register_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<Dio>(() => DioClient().dio);

  // Data sources
  getIt.registerLazySingleton<MockAuthRemoteDataSource>(() => MockAuthRemoteDataSource());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt()),
  );
  
  // Use cases
  
  // Blocs
  getIt.registerFactory(() => LoginCubit(getIt()));
  getIt.registerFactory(() => RegisterCubit(getIt()));
}

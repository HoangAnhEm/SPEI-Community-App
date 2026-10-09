import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/mock_auth_remote_data_source.dart';
import '../../data/datasources/local/local_data_source.dart';
import '../../data/datasources/local/local_data_source_impl.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/blocs/login/login_cubit.dart';
import '../../presentation/blocs/register/register_cubit.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<Dio>(() => DioClient().dio);

  // Data sources
  getIt.registerLazySingleton<MockAuthRemoteDataSource>(() => MockAuthRemoteDataSource());
  getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl(getIt(), getIt()));
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt(), localDataSource: getIt()),
  );
  
  // Use cases
  
  // Blocs
  getIt.registerLazySingleton(() => AuthBloc(getIt()));
  getIt.registerFactory(() => LoginCubit(getIt()));
  getIt.registerFactory(() => RegisterCubit(getIt()));
}

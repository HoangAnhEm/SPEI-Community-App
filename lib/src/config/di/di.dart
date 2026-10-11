import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/local/local_data_source.dart';
import '../../data/datasources/local/local_data_source_impl.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/blocs/login/login_cubit.dart';
import '../../presentation/blocs/register/register_cubit.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/recovery/recovery_cubit.dart';
import '../../presentation/blocs/change_password/change_password_cubit.dart';

import '../../presentation/blocs/auth/auth_event.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl(getIt(), getIt()));
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(
    getIt(),
    onSessionExpired: () {
      getIt<AuthBloc>().add(AuthLogoutRequested());
    },
  ));
  getIt.registerLazySingleton<Dio>(() => getIt<ApiClient>().dio);

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(getIt()));
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt(), localDataSource: getIt()),
  );
  
  // Use cases
  
  // Blocs
  getIt.registerLazySingleton(() => AuthBloc(getIt()));
  getIt.registerFactory(() => LoginCubit(getIt()));
  getIt.registerFactory(() => RegisterCubit(getIt()));
  getIt.registerFactory(() => RecoveryCubit(getIt()));
  getIt.registerFactory(() => ChangePasswordCubit(getIt()));
}

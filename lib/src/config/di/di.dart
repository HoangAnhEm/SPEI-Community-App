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
import '../../domain/repositories/household_repository.dart';
import '../../data/datasources/remote/household_remote_data_source.dart';
import '../../data/repositories_impl/household_repository_impl.dart';
import '../../domain/repositories/emission_repository.dart';
import '../../data/datasources/remote/emission_remote_data_source.dart';
import '../../data/repositories_impl/emission_repository_impl.dart';
import '../../domain/repositories/incident_repository.dart';
import '../../data/datasources/remote/incident_remote_data_source.dart';
import '../../data/repositories_impl/incident_repository_impl.dart';
import '../../presentation/blocs/login/login_cubit.dart';
import '../../presentation/blocs/register/register_cubit.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/recovery/recovery_cubit.dart';
import '../../presentation/blocs/change_password/change_password_cubit.dart';
import '../../presentation/blocs/create_household/create_household_cubit.dart';
import '../../presentation/blocs/household/household_cubit.dart';
import '../../presentation/blocs/emission/emission_cubit.dart';
import '../../presentation/blocs/household_lookup/household_lookup_cubit.dart';
import '../../presentation/blocs/sent_invitations/sent_invitations_cubit.dart';
import '../../presentation/blocs/household_join_requests/household_join_requests_cubit.dart';
import '../../presentation/blocs/invite_user/invite_user_cubit.dart';
import '../../presentation/blocs/received_invitations/received_invitations_cubit.dart';
import '../../presentation/blocs/my_join_requests/my_join_requests_cubit.dart';

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
  getIt.registerLazySingleton<HouseholdRemoteDataSource>(() => HouseholdRemoteDataSource(getIt()));
  getIt.registerLazySingleton<EmissionRemoteDataSource>(() => EmissionRemoteDataSource(getIt()));
  getIt.registerLazySingleton<IncidentRemoteDataSource>(() => IncidentRemoteDataSource(getIt()));
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt(), localDataSource: getIt()),
  );
  getIt.registerLazySingleton<HouseholdRepository>(
    () => HouseholdRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<EmissionRepository>(
    () => EmissionRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<IncidentRepository>(
    () => IncidentRepositoryImpl(remoteDataSource: getIt()),
  );
  
  // Use cases
  
  // Blocs
  getIt.registerLazySingleton(() => AuthBloc(getIt()));
  getIt.registerLazySingleton(() => HouseholdCubit(getIt()));
  getIt.registerLazySingleton(() => EmissionCubit(getIt()));
  getIt.registerFactory(() => LoginCubit(getIt()));
  getIt.registerFactory(() => RegisterCubit(getIt()));
  getIt.registerFactory(() => RecoveryCubit(getIt()));
  getIt.registerFactory(() => ChangePasswordCubit(getIt()));
  getIt.registerFactory(() => CreateHouseholdCubit(getIt()));
  getIt.registerFactory(() => HouseholdLookupCubit(getIt()));
  getIt.registerFactory(() => SentInvitationsCubit(getIt()));
  getIt.registerFactory(() => HouseholdJoinRequestsCubit(getIt()));
  getIt.registerFactory(() => InviteUserCubit(getIt()));
  getIt.registerFactory(() => ReceivedInvitationsCubit(getIt()));
  getIt.registerFactory(() => MyJoinRequestsCubit(getIt()));
}

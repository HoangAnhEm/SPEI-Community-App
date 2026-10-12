import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/config/di/di.dart';
import 'src/config/routes/app_routes.dart';
import 'src/presentation/blocs/auth/auth_bloc.dart';
import 'src/presentation/blocs/auth/auth_event.dart';

import 'src/presentation/blocs/household/household_cubit.dart';
import 'src/presentation/blocs/emission/emission_cubit.dart';
import 'src/presentation/blocs/incident/incident_cubit.dart';
import 'src/presentation/blocs/chat/chat_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Làm trong suốt status bar
    statusBarIconBrightness: Brightness.dark, // Đổi màu icon trên status bar thành màu tối
  ));

  // Khởi tạo các dependencies
  await setupDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(AppStarted()),
          lazy: false,
        ),
        BlocProvider<HouseholdCubit>(
          create: (context) => getIt<HouseholdCubit>(),
          lazy: false,
        ),
        BlocProvider<EmissionCubit>(
          create: (context) => getIt<EmissionCubit>(),
          lazy: false,
        ),
        BlocProvider<IncidentCubit>(
          create: (context) => getIt<IncidentCubit>()..loadMyIncidents(),
          lazy: false,
        ),
        BlocProvider<ChatCubit>(
          create: (context) => getIt<ChatCubit>(),
          lazy: false,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Spei Community',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B7D53)),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/config/di/di.dart';
import 'src/config/routes/app_routes.dart';

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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Spei Community',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

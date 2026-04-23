import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/bindings/app_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final storageService = StorageService(preferences);

  Get.put<StorageService>(storageService, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medic Patient App',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialBinding: AppBinding(),
      initialRoute: storageService.hasToken ? AppRoutes.home : AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}

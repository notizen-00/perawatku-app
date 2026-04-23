import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/bindings/app_binding.dart';
import 'core/controllers/app_theme_controller.dart';
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
    final themeController = Get.isRegistered<AppThemeController>()
        ? Get.find<AppThemeController>()
        : Get.put(AppThemeController(), permanent: true);
    final storageService = Get.find<StorageService>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Medic Patient App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        initialBinding: AppBinding(),
        initialRoute: storageService.hasToken ? AppRoutes.home : AppRoutes.login,
        getPages: AppPages.routes,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    themeMode.value =
        isDarkMode ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(themeMode.value);
  }
}

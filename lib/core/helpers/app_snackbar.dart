import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_rounded,
    );
  }

  static void error(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_rounded,
    );
  }

  static void info(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_rounded,
    );
  }

  static void notification(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.primary,
      icon: Icons.notifications_active_rounded,
      snackPosition: SnackPosition.TOP,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    final glassColor = backgroundColor.withValues(alpha: 0.18);
    final borderColor = backgroundColor.withValues(alpha: 0.35);

    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: glassColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      duration: const Duration(seconds: 3),
      icon: Icon(icon, color: Colors.white),
      shouldIconPulse: false,
      borderColor: borderColor,
      borderWidth: 1.2,
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withValues(alpha: 0.18),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
      overlayBlur: 2.5,
      snackStyle: SnackStyle.FLOATING,
    );
  }
}

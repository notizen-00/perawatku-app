import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../notification/presentation/controllers/notification_controller.dart';

class HomeTopHeader extends StatelessWidget {
  HomeTopHeader({super.key});

  final NotificationController notificationController =
      Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchFill = isDark ? const Color(0xFF12211F) : AppColors.softWhite;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(AppRoutes.search),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: searchFill,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : const Color(0xFFEAE3D8),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.lightMutedText,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Cari layanan kesehatan',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.lightMutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => _CircleButton(
            icon: Icons.notifications_rounded,
            badge: notificationController.unreadCount.value == 0
                ? null
                : notificationController.unreadCount.value > 99
                ? '99+'
                : notificationController.unreadCount.value.toString(),
            onTap: () => Get.toNamed(AppRoutes.notifications),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap, this.badge});

  final IconData icon;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF12211F) : AppColors.softWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFEAE3D8),
              ),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/home_controller.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Obx(
      () => SafeArea(
        top: false,
        child: SizedBox(
          height: 104 + bottomInset,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 80 + bottomInset,
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 12 + bottomInset),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C1514) : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BottomItem(
                        icon: Icons.home_rounded,
                        label: 'Beranda',
                        selected: controller.selectedBottomNavIndex.value == 0,
                        onTap: () => controller.selectBottomNav(0),
                      ),
                      _BottomItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Aktivitas',
                        selected: controller.selectedBottomNavIndex.value == 1,
                        onTap: () => controller.selectBottomNav(1),
                      ),
                      const SizedBox(width: 78),
                      _BottomItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Chat',
                        badge: '1',
                        selected: controller.selectedBottomNavIndex.value == 3,
                        onTap: () => controller.selectBottomNav(3),
                      ),
                      _BottomItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Akun',
                        selected: controller.selectedBottomNavIndex.value == 4,
                        onTap: () => controller.selectBottomNav(4),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 2,
                child: _CenterMedicButton(
                  selected: controller.selectedBottomNavIndex.value == 2,
                  onTap: () => controller.selectBottomNav(2),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final activeColor = selected ? AppColors.primary : const Color(0xFF4E4E4E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: activeColor, size: 24),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -1,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
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
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: activeColor,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterMedicButton extends StatelessWidget {
  const _CenterMedicButton({
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: selected
                ? AppColors.secondary
                : (isDark ? const Color(0xFF0C1514) : Colors.white),
            width: 4,
          ),
        ),
        child: const Icon(
          Icons.local_hospital_rounded,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }
}

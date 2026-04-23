import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/home_controller.dart';

class HomeGreenPromoBanner extends StatelessWidget {
  const HomeGreenPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<HomeController>();

    return Obx(
      () {
        final state = controller.locationState.value;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: isDark
                  ? const [
                      Color(0xFF103130),
                      Color(0xFF116A67),
                      Color(0xFF18A59F),
                    ]
                  : const [
                      Color(0xFFDDFBF2),
                      Color(0xFFB7F5E1),
                      Color(0xFF86E8CA),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFCDEFE4),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0E4944),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C6D67),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: controller.fetchCurrentLocation,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          state.actionLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      state.hasError
                          ? Icons.location_off_rounded
                          : Icons.place_rounded,
                      size: 44,
                      color:
                          state.hasError ? AppColors.error : AppColors.primary,
                    ),
                    Positioned(
                      bottom: 12,
                      child: state.isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFFEF4444),
                              ),
                            )
                          : const Icon(
                              Icons.my_location_rounded,
                              size: 18,
                              color: Color(0xFFEF4444),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

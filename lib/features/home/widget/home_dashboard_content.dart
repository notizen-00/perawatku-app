import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../activity/presentation/controllers/activity_controller.dart';
import '../controller/home_controller.dart';
import 'home_balance_panel.dart';
import 'home_green_promo_banner.dart';
import 'home_hero_promo.dart';
import 'home_nearby_nurses_section.dart';
import 'home_rebooking_section.dart';
import 'home_service_grid.dart';
import 'home_top_header.dart';

class HomeDashboardContent extends StatelessWidget {
  const HomeDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeController = Get.find<HomeController>();

    return RefreshIndicator(
      onRefresh: () async {
        await homeController.refreshHome();
        if (Get.isRegistered<ActivityController>()) {
          await Get.find<ActivityController>().loadActivities();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 27, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeTopHeader(),
            const SizedBox(height: 18),
            HomeHeroPromo(isDark: isDark),
            const SizedBox(height: 16),
            const HomeBalancePanel(),
            const SizedBox(height: 18),
            HomeServiceGrid(),
            const SizedBox(height: 18),
            const HomeGreenPromoBanner(),
            const SizedBox(height: 18),
            const HomeRebookingSection(),
            const SizedBox(height: 18),
            const HomeNearbyNursesSection(),
          ],
        ),
      ),
    );
  }
}

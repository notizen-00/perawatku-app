import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../activity/presentation/pages/activity_page.dart';
import '../../account/presentation/account_page.dart';
import '../../nurse/domain/usecases/get_nurses_use_case.dart';
import '../controller/home_controller.dart';
import '../widget/home_bottom_bar.dart';
import '../widget/home_dashboard_content.dart';
import '../widget/home_placeholder_page.dart';

class MedicHomePage extends StatelessWidget {
  MedicHomePage({super.key});

  final HomeController controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(
          HomeController(
            Get.find<GetNursesUseCase>(),
          ),
        );

  List<Widget> get _pages => [
        const HomeDashboardContent(),
        ActivityPage(),
        const HomePlaceholderPage(
          title: 'Medic',
          icon: Icons.local_hospital_rounded,
          description: 'Pusat akses cepat layanan medis akan ditampilkan di sini.',
        ),
        const HomePlaceholderPage(
          title: 'Chat',
          icon: Icons.chat_bubble_outline_rounded,
          description:
              'Percakapan dengan admin atau tenaga kesehatan akan muncul di sini.',
        ),
        AccountPage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedBottomNavIndex.value,
          children: _pages,
        ),
      ),
      bottomNavigationBar: HomeBottomBar(controller: controller),
    );
  }
}

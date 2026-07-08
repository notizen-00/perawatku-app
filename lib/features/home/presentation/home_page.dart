import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../activity/presentation/pages/activity_page.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../activity/domain/usecases/get_consultation_activities_use_case.dart';
import '../../activity/domain/usecases/get_medicine_purchase_activities_use_case.dart';
import '../../activity/domain/usecases/get_other_activities_use_case.dart';
import '../../account/presentation/account_page.dart';
import '../../nurse/domain/usecases/get_nurses_use_case.dart';
import '../../service_booking/domain/usecases/get_service_booking_services_use_case.dart';
import '../../service_booking/presentation/pages/service_matchmaking_page.dart';
import '../controller/home_controller.dart';
import '../widget/active_order_status_overlay.dart';
import '../widget/home_bottom_bar.dart';
import '../widget/home_dashboard_content.dart';
import '../widget/home_placeholder_page.dart';

class MedicHomePage extends StatelessWidget {
  MedicHomePage({super.key});

  final HomeController controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(
          HomeController(
            getNursesUseCase: Get.find<GetNursesUseCase>(),
            getServicesUseCase: Get.find<GetServiceBookingServicesUseCase>(),
          ),
        );

  final ActivityController activityController =
      Get.isRegistered<ActivityController>()
      ? Get.find<ActivityController>()
      : Get.put(
          ActivityController(
            getConsultationActivitiesUseCase:
                Get.find<GetConsultationActivitiesUseCase>(),
            getMedicinePurchaseActivitiesUseCase:
                Get.find<GetMedicinePurchaseActivitiesUseCase>(),
            getOtherActivitiesUseCase: Get.find<GetOtherActivitiesUseCase>(),
          ),
        );

  List<Widget> get _pages => [
    const HomeDashboardContent(),
    ActivityPage(),
    const ServiceMatchmakingPage(),
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
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Obx(
            () => AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: activityController.visibleActiveOrder == null ? 0 : 98,
              ),
              child: IndexedStack(
                index: controller.selectedBottomNavIndex.value,
                children: _pages,
              ),
            ),
          ),
          ActiveOrderStatusOverlay(
            activityController: activityController,
            homeController: controller,
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomBar(controller: controller),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/midtrans_service.dart';
import '../../../home/controller/home_controller.dart';
import '../../../patient_member/domain/usecases/get_patient_members_use_case.dart';
import '../../domain/usecases/cancel_service_booking_use_case.dart';
import '../../domain/usecases/check_promo_code_use_case.dart';
import '../../domain/usecases/confirm_service_booking_completion_use_case.dart';
import '../../domain/usecases/create_service_booking_use_case.dart';
import '../../domain/usecases/get_service_booking_services_use_case.dart';
import '../../domain/usecases/get_service_booking_use_case.dart';
import '../../../nurse/domain/usecases/get_nurses_use_case.dart';
import '../../domain/usecases/pay_service_booking_use_case.dart';
import '../../domain/usecases/rematch_service_booking_use_case.dart';
import '../controllers/service_booking_controller.dart';
import '../widgets/service_booking_panel.dart';

class ServiceMatchmakingPage extends StatelessWidget {
  const ServiceMatchmakingPage({super.key});

  ServiceBookingController _ensureController() {
    if (Get.isRegistered<ServiceBookingController>()) {
      return Get.find<ServiceBookingController>();
    }

    return Get.put(
      ServiceBookingController(
        getNursesUseCase: Get.find<GetNursesUseCase>(),
        getServicesUseCase: Get.find<GetServiceBookingServicesUseCase>(),
        createBookingUseCase: Get.find<CreateServiceBookingUseCase>(),
        getBookingUseCase: Get.find<GetServiceBookingUseCase>(),
        payBookingUseCase: Get.find<PayServiceBookingUseCase>(),
        rematchBookingUseCase: Get.find<RematchServiceBookingUseCase>(),
        confirmCompletionUseCase:
            Get.find<ConfirmServiceBookingCompletionUseCase>(),
        cancelBookingUseCase: Get.find<CancelServiceBookingUseCase>(),
        checkPromoCodeUseCase: Get.find<CheckPromoCodeUseCase>(),
        getPatientMembersUseCase: Get.find<GetPatientMembersUseCase>(),
        midtransService: Get.find<MidtransService>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nurseController = _ensureController();
    _applyRequestedService(nurseController);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: const [
          Text(
            'Pesan Layanan',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            'Pilih layanan, profil pasien, dan jadwal. Kami akan mencarikan mitra yang sesuai.',
          ),
          SizedBox(height: 16),
          ServiceBookingPanel(),
        ],
      ),
    );
  }

  void _applyRequestedService(ServiceBookingController nurseController) {
    if (!Get.isRegistered<HomeController>()) {
      return;
    }

    final homeController = Get.find<HomeController>();
    final serviceId = homeController.requestedMatchmakingServiceId.value;
    if (serviceId == null || serviceId <= 0) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final selected = await nurseController.selectServiceByBookingServiceId(
        serviceId,
      );
      if (selected) {
        homeController.requestedMatchmakingServiceId.value = null;
      }
    });
  }
}

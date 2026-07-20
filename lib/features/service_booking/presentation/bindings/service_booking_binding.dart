import 'package:get/get.dart';

import '../../../../core/services/midtrans_service.dart';
import '../../../nurse/domain/usecases/get_nurses_use_case.dart';
import '../../../patient_member/domain/usecases/get_patient_members_use_case.dart';
import '../../domain/usecases/cancel_service_booking_use_case.dart';
import '../../domain/usecases/check_promo_code_use_case.dart';
import '../../domain/usecases/confirm_service_booking_completion_use_case.dart';
import '../../domain/usecases/create_service_booking_use_case.dart';
import '../../domain/usecases/get_service_booking_services_use_case.dart';
import '../../domain/usecases/get_service_booking_tracking_use_case.dart';
import '../../domain/usecases/get_service_booking_use_case.dart';
import '../../domain/usecases/pay_service_booking_use_case.dart';
import '../../domain/usecases/rematch_service_booking_use_case.dart';
import '../controllers/service_booking_controller.dart';

class ServiceBookingBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<ServiceBookingController>()) {
      return;
    }

    Get.put<ServiceBookingController>(
      ServiceBookingController(
        getNursesUseCase: Get.find<GetNursesUseCase>(),
        getServicesUseCase: Get.find<GetServiceBookingServicesUseCase>(),
        createBookingUseCase: Get.find<CreateServiceBookingUseCase>(),
        getBookingUseCase: Get.find<GetServiceBookingUseCase>(),
        getTrackingUseCase: Get.find<GetServiceBookingTrackingUseCase>(),
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
}

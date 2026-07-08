import 'package:get/get.dart';

import '../../../../core/services/midtrans_service.dart';
import '../../../patient_member/domain/usecases/get_patient_members_use_case.dart';
import '../../domain/usecases/check_promo_code_use_case.dart';
import '../../domain/usecases/create_service_booking_use_case.dart';
import '../../domain/usecases/get_service_booking_services_use_case.dart';
import '../../domain/usecases/get_service_booking_use_case.dart';
import '../../domain/usecases/get_nurses_use_case.dart';
import '../../domain/usecases/pay_service_booking_use_case.dart';
import '../controllers/nurse_controller.dart';

class NurseBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<NurseController>()) {
      return;
    }

    Get.lazyPut<NurseController>(
      () => NurseController(
        getNursesUseCase: Get.find<GetNursesUseCase>(),
        getServicesUseCase: Get.find<GetServiceBookingServicesUseCase>(),
        createBookingUseCase: Get.find<CreateServiceBookingUseCase>(),
        getBookingUseCase: Get.find<GetServiceBookingUseCase>(),
        payBookingUseCase: Get.find<PayServiceBookingUseCase>(),
        checkPromoCodeUseCase: Get.find<CheckPromoCodeUseCase>(),
        getPatientMembersUseCase: Get.find<GetPatientMembersUseCase>(),
        midtransService: Get.find<MidtransService>(),
      ),
    );
  }
}

import 'package:get/get.dart';

import '../../../../core/services/midtrans_service.dart';
import '../../domain/usecases/create_service_booking_use_case.dart';
import '../../domain/usecases/get_service_booking_services_use_case.dart';
import '../../domain/usecases/get_service_booking_use_case.dart';
import '../../domain/usecases/get_nurses_use_case.dart';
import '../../domain/usecases/pay_service_booking_use_case.dart';
import '../controllers/nurse_controller.dart';

class NurseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NurseController>(
      () => NurseController(
        getNursesUseCase: Get.find<GetNursesUseCase>(),
        getServicesUseCase: Get.find<GetServiceBookingServicesUseCase>(),
        createBookingUseCase: Get.find<CreateServiceBookingUseCase>(),
        getBookingUseCase: Get.find<GetServiceBookingUseCase>(),
        payBookingUseCase: Get.find<PayServiceBookingUseCase>(),
        midtransService: Get.find<MidtransService>(),
      ),
    );
  }
}

import 'package:get/get.dart';

import '../../domain/usecases/get_doctors_use_case.dart';
import '../controllers/doctor_controller.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorController>(
      () => DoctorController(Get.find<GetDoctorsUseCase>()),
    );
  }
}

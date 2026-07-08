import 'package:get/get.dart';

import '../../domain/usecases/get_nurses_use_case.dart';
import '../controllers/nurse_controller.dart';

class NurseBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<NurseController>()) {
      return;
    }

    Get.lazyPut<NurseController>(
      () => NurseController(getNursesUseCase: Get.find<GetNursesUseCase>()),
    );
  }
}

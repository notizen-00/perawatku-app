import 'package:get/get.dart';

import '../../domain/usecases/get_nurses_use_case.dart';
import '../controllers/nurse_controller.dart';

class NurseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NurseController>(
      () => NurseController(Get.find<GetNursesUseCase>()),
    );
  }
}

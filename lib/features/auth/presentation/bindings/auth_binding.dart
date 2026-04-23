import 'package:get/get.dart';

import '../../domain/usecases/login_use_case.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<LoginUseCase>()),
    );
  }
}

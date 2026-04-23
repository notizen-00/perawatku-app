import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/data/models/auth_user_model.dart';

class AccountController extends GetxController {
  AccountController(this._storageService);

  final StorageService _storageService;

  final Rxn<AuthUserModel> user = Rxn<AuthUserModel>();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    final userJson = _storageService.userJson;
    if (userJson == null) {
      user.value = null;
      return;
    }

    user.value = AuthUserModel.fromJson(userJson);
  }

  Future<void> logout() async {
    await _storageService.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}

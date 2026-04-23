import 'package:get/get.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/home/data/datasources/nurse_remote_data_source.dart';
import '../controllers/app_theme_controller.dart';
import '../network/api_client.dart';
import '../services/storage_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppThemeController>()) {
      Get.put(AppThemeController(), permanent: true);
    }

    Get.lazyPut<ApiClient>(
      () => ApiClient(storageService: Get.find<StorageService>()),
      fenix: true,
    );

    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<NurseRemoteDataSource>(
      () => NurseRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(Get.find<NurseRemoteDataSource>()), permanent: true);
    }

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(Get.find<AuthRepository>()),
      fenix: true,
    );
  }
}

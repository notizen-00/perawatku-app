import 'package:get/get.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/doctor/data/datasources/doctor_remote_data_source.dart';
import '../../features/doctor/data/repositories/doctor_repository_impl.dart';
import '../../features/doctor/domain/repositories/doctor_repository.dart';
import '../../features/doctor/domain/usecases/get_doctors_use_case.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/nurse/data/datasources/nurse_remote_data_source.dart';
import '../../features/nurse/data/repositories/nurse_repository_impl.dart';
import '../../features/nurse/domain/repositories/nurse_repository.dart';
import '../../features/nurse/domain/usecases/get_nurses_use_case.dart';
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

    Get.lazyPut<NurseRepository>(
      () => NurseRepositoryImpl(
        remoteDataSource: Get.find<NurseRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetNursesUseCase>(
      () => GetNursesUseCase(Get.find<NurseRepository>()),
      fenix: true,
    );

    Get.lazyPut<DoctorRemoteDataSource>(
      () => DoctorRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<DoctorRepository>(
      () => DoctorRepositoryImpl(
        remoteDataSource: Get.find<DoctorRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetDoctorsUseCase>(
      () => GetDoctorsUseCase(Get.find<DoctorRepository>()),
      fenix: true,
    );

    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(Get.find<GetNursesUseCase>()), permanent: true);
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

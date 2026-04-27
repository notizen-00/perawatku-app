import 'package:get/get.dart';

import '../../features/activity/data/datasources/activity_remote_data_source.dart';
import '../../features/activity/data/repositories/activity_repository_impl.dart';
import '../../features/activity/domain/repositories/activity_repository.dart';
import '../../features/activity/domain/usecases/get_consultation_activities_use_case.dart';
import '../../features/activity/domain/usecases/get_medicine_purchase_activities_use_case.dart';
import '../../features/activity/domain/usecases/get_other_activities_use_case.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/consultation/data/datasources/consultation_remote_data_source.dart';
import '../../features/consultation/data/repositories/consultation_repository_impl.dart';
import '../../features/consultation/domain/repositories/consultation_repository.dart';
import '../../features/consultation/domain/usecases/create_consultation_use_case.dart';
import '../../features/consultation/domain/usecases/get_consultation_use_case.dart';
import '../../features/consultation/domain/usecases/pay_consultation_use_case.dart';
import '../../features/consultation/domain/usecases/send_consultation_message_use_case.dart';
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

    Get.lazyPut<ActivityRemoteDataSource>(
      () => ActivityRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<ActivityRepository>(
      () => ActivityRepositoryImpl(
        remoteDataSource: Get.find<ActivityRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetConsultationActivitiesUseCase>(
      () => GetConsultationActivitiesUseCase(Get.find<ActivityRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetMedicinePurchaseActivitiesUseCase>(
      () => GetMedicinePurchaseActivitiesUseCase(Get.find<ActivityRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetOtherActivitiesUseCase>(
      () => GetOtherActivitiesUseCase(Get.find<ActivityRepository>()),
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

    Get.lazyPut<ConsultationRemoteDataSource>(
      () => ConsultationRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<ConsultationRepository>(
      () => ConsultationRepositoryImpl(
        remoteDataSource: Get.find<ConsultationRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CreateConsultationUseCase>(
      () => CreateConsultationUseCase(Get.find<ConsultationRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetConsultationUseCase>(
      () => GetConsultationUseCase(Get.find<ConsultationRepository>()),
      fenix: true,
    );

    Get.lazyPut<PayConsultationUseCase>(
      () => PayConsultationUseCase(Get.find<ConsultationRepository>()),
      fenix: true,
    );

    Get.lazyPut<SendConsultationMessageUseCase>(
      () => SendConsultationMessageUseCase(
        Get.find<ConsultationRepository>(),
      ),
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

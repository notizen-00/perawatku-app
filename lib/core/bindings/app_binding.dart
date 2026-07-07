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
import '../../features/nurse/data/datasources/service_booking_remote_data_source.dart';
import '../../features/nurse/data/repositories/nurse_repository_impl.dart';
import '../../features/nurse/data/repositories/service_booking_repository_impl.dart';
import '../../features/nurse/domain/repositories/nurse_repository.dart';
import '../../features/nurse/domain/repositories/service_booking_repository.dart';
import '../../features/nurse/domain/usecases/create_service_booking_use_case.dart';
import '../../features/nurse/domain/usecases/get_service_booking_services_use_case.dart';
import '../../features/nurse/domain/usecases/get_service_booking_use_case.dart';
import '../../features/nurse/domain/usecases/get_nurses_use_case.dart';
import '../../features/nurse/domain/usecases/pay_service_booking_use_case.dart';
import '../../features/notification/data/datasources/notification_remote_data_source.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/presentation/controllers/notification_controller.dart';
import '../../features/patient_member/data/datasources/patient_member_remote_data_source.dart';
import '../../features/patient_member/data/repositories/patient_member_repository_impl.dart';
import '../../features/patient_member/domain/repositories/patient_member_repository.dart';
import '../../features/patient_member/domain/usecases/delete_patient_member_use_case.dart';
import '../../features/patient_member/domain/usecases/get_patient_members_use_case.dart';
import '../../features/patient_member/domain/usecases/save_patient_member_use_case.dart';
import '../../features/patient_member/domain/usecases/set_primary_patient_member_use_case.dart';
import '../../features/patient_member/presentation/controllers/patient_member_controller.dart';
import '../controllers/app_theme_controller.dart';
import '../network/api_client.dart';
import '../services/reverb_websocket_service.dart';
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

    Get.lazyPut<ReverbWebSocketService>(
      () => ReverbWebSocketService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: Get.find<NotificationRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<NotificationController>(
      () => NotificationController(
        notificationRepository: Get.find<NotificationRepository>(),
        reverbWebSocketService: Get.find<ReverbWebSocketService>(),
        storageService: Get.find<StorageService>(),
      ),
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
      () =>
          GetMedicinePurchaseActivitiesUseCase(Get.find<ActivityRepository>()),
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

    Get.lazyPut<ServiceBookingRemoteDataSource>(
      () =>
          ServiceBookingRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<ServiceBookingRepository>(
      () => ServiceBookingRepositoryImpl(
        remoteDataSource: Get.find<ServiceBookingRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetServiceBookingServicesUseCase>(
      () => GetServiceBookingServicesUseCase(
        Get.find<ServiceBookingRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CreateServiceBookingUseCase>(
      () => CreateServiceBookingUseCase(Get.find<ServiceBookingRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetServiceBookingUseCase>(
      () => GetServiceBookingUseCase(Get.find<ServiceBookingRepository>()),
      fenix: true,
    );

    Get.lazyPut<PayServiceBookingUseCase>(
      () => PayServiceBookingUseCase(Get.find<ServiceBookingRepository>()),
      fenix: true,
    );

    Get.lazyPut<PatientMemberRemoteDataSource>(
      () => PatientMemberRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<PatientMemberRepository>(
      () => PatientMemberRepositoryImpl(
        remoteDataSource: Get.find<PatientMemberRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetPatientMembersUseCase>(
      () => GetPatientMembersUseCase(Get.find<PatientMemberRepository>()),
      fenix: true,
    );

    Get.lazyPut<SavePatientMemberUseCase>(
      () => SavePatientMemberUseCase(Get.find<PatientMemberRepository>()),
      fenix: true,
    );

    Get.lazyPut<SetPrimaryPatientMemberUseCase>(
      () => SetPrimaryPatientMemberUseCase(Get.find<PatientMemberRepository>()),
      fenix: true,
    );

    Get.lazyPut<DeletePatientMemberUseCase>(
      () => DeletePatientMemberUseCase(Get.find<PatientMemberRepository>()),
      fenix: true,
    );

    Get.lazyPut<PatientMemberController>(
      () => PatientMemberController(
        getMembersUseCase: Get.find<GetPatientMembersUseCase>(),
        saveMemberUseCase: Get.find<SavePatientMemberUseCase>(),
        setPrimaryUseCase: Get.find<SetPrimaryPatientMemberUseCase>(),
        deleteMemberUseCase: Get.find<DeletePatientMemberUseCase>(),
      ),
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
      () => SendConsultationMessageUseCase(Get.find<ConsultationRepository>()),
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

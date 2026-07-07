import 'package:get/get.dart';

import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/doctor/presentation/bindings/doctor_chat_binding.dart';
import '../../features/doctor/presentation/bindings/doctor_binding.dart';
import '../../features/doctor/presentation/pages/doctor_consultation_page.dart';
import '../../features/doctor/presentation/pages/doctor_chat_page.dart';
import '../../features/doctor/presentation/pages/doctor_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/screen/search_page.dart';
import '../../features/map/presentation/bindings/map_binding.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/nurse/presentation/bindings/nurse_binding.dart';
import '../../features/nurse/presentation/pages/nurse_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/patient_member/presentation/pages/patient_member_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.home, page: () => MedicHomePage()),
    GetPage(name: AppRoutes.search, page: () => SearchPage()),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationPage(),
    ),
    GetPage(
      name: AppRoutes.nurses,
      page: () => const NursePage(),
      binding: NurseBinding(),
    ),
    GetPage(
      name: AppRoutes.doctors,
      page: () => const DoctorPage(),
      binding: DoctorBinding(),
    ),
    GetPage(
      name: AppRoutes.patientMembers,
      page: () => const PatientMemberPage(),
    ),
    GetPage(
      name: AppRoutes.doctorConsultation,
      page: () => const DoctorConsultationPage(),
      binding: DoctorChatBinding(),
    ),
    GetPage(
      name: AppRoutes.doctorChat,
      page: () => const DoctorChatPage(),
      binding: DoctorChatBinding(),
    ),
    GetPage(
      name: AppRoutes.map,
      page: () => const MapPage(),
      binding: MapBinding(),
    ),
  ];
}

import 'package:get/get.dart';

import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/screen/search_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => MedicHomePage(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => SearchPage(),
    ),
  ];
}

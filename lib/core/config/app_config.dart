import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String baseUrl = 'https://obliging-largely-yeti.ngrok-free.app';

  static bool get isDev => kDebugMode;

  static bool get shouldUseNgrokHeader =>
      isDev && baseUrl.contains('ngrok-free.app');
}

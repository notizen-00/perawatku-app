import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String baseUrl = 'https://backend.perawatku.tech';
  static const String reverbKey = 'medic-app-key';
  static const String reverbHost = 'backend.perawatku.tech';
  static const int reverbPort = 443;
  static const bool reverbUseTls = true;
  static const String midtransClientKey = String.fromEnvironment(
    'MIDTRANS_CLIENT_KEY',
    defaultValue: 'SB-Mid-client-Wg5leIiJk3ql0n75',
  );
  static const String midtransMerchantBaseUrl = String.fromEnvironment(
    'MIDTRANS_MERCHANT_BASE_URL',
    defaultValue: baseUrl,
  );

  static bool get isDev => kDebugMode;

  static bool get shouldUseNgrokHeader =>
      isDev && baseUrl.contains('ngrok-free.app');

  static String get reverbScheme => reverbUseTls ? 'wss' : 'ws';

  static String get reverbAuthEndpoint => '$baseUrl/api/broadcasting/auth';

  static Uri get reverbUri => Uri(
    scheme: reverbScheme,
    host: reverbHost,
    port: reverbPort,
    path: '/app/$reverbKey',
    queryParameters: const {
      'protocol': '7',
      'client': 'flutter',
      'version': '1.0.0',
      'flash': 'false',
    },
  );
}

import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String baseUrl = 'https://obliging-largely-yeti.ngrok-free.app';
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
}

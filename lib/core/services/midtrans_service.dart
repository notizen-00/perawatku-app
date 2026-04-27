import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

import '../config/app_config.dart';
import '../theme/app_colors.dart';

class MidtransService {
  MidtransSDK? _sdk;
  bool _isInitialized = false;
  ValueChanged<TransactionResult>? _transactionFinishedCallback;

  bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get isConfigured =>
      AppConfig.midtransClientKey.trim().isNotEmpty &&
      AppConfig.midtransMerchantBaseUrl.trim().isNotEmpty;

  Future<void> initialize() async {
    if (_isInitialized || !isSupportedPlatform || !isConfigured) {
      return;
    }

    _sdk = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: AppConfig.midtransClientKey,
        merchantBaseUrl: AppConfig.midtransMerchantBaseUrl,
        enableLog: AppConfig.isDev,
        colorTheme: ColorTheme(
          colorPrimary: AppColors.primary,
          colorPrimaryDark: AppColors.primary,
          colorSecondary: AppColors.secondary,
        ),
      ),
    );

    _sdk?.setTransactionFinishedCallback((result) {
      _transactionFinishedCallback?.call(result);
    });

    _isInitialized = true;
  }

  Future<void> startPayment({
    required String snapToken,
  }) async {
    await initialize();

    final sdk = _sdk;
    if (sdk == null) {
      throw StateError(
        'Midtrans belum siap. Pastikan client key dan platform sudah benar.',
      );
    }

    await sdk.startPaymentUiFlow(token: snapToken);
  }

  Future<void> setTransactionFinishedCallback(
    ValueChanged<TransactionResult> onFinished,
  ) async {
    _transactionFinishedCallback = onFinished;
    await initialize();
  }

  void removeTransactionFinishedCallback() {
    _transactionFinishedCallback = null;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helpers/app_snackbar.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  AuthController(this._loginUseCase);

  final LoginUseCase _loginUseCase;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.info(
        'Validasi',
        'Email dan password wajib diisi.',
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _loginUseCase(email: email, password: password);

      AppSnackbar.success(
        'Berhasil',
        result.message,
      );

      Get.offAllNamed(AppRoutes.home);
    } on AppException catch (error) {
      AppSnackbar.error(
        'Login Gagal',
        error.message,
      );
    } catch (_) {
      AppSnackbar.error(
        'Login Gagal',
        'Terjadi kesalahan tak terduga.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

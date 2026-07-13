import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FBFA),
        foregroundColor: AppColors.primary,
        title: const Text(
          'Daftar Pasien',
          style: TextStyle(
            color: AppColors.lightText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RegisterHero(),
              const SizedBox(height: 20),
              _RegisterCard(
                child: Column(
                  children: [
                    TextField(
                      controller: controller.registerNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.badge_rounded),
                        labelText: 'Nama lengkap',
                        hintText: 'Budi Santoso',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.registerEmailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_rounded),
                        labelText: 'Email',
                        hintText: 'nama@email.com',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.registerPhoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_rounded),
                        labelText: 'Nomor HP',
                        hintText: '08123456789',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextField(
                        controller: controller.registerPasswordController,
                        obscureText: controller.obscureRegisterPassword.value,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_rounded),
                          labelText: 'Kata sandi',
                          hintText: 'Minimal 8 karakter',
                          suffixIcon: IconButton(
                            onPressed:
                                controller.toggleRegisterPasswordVisibility,
                            icon: Icon(
                              controller.obscureRegisterPassword.value
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextField(
                        controller:
                            controller.registerPasswordConfirmationController,
                        obscureText:
                            controller.obscureRegisterPasswordConfirmation.value,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => controller.register(),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_reset_rounded),
                          labelText: 'Konfirmasi kata sandi',
                          hintText: 'Ulangi kata sandi',
                          suffixIcon: IconButton(
                            onPressed: controller
                                .toggleRegisterPasswordConfirmationVisibility,
                            icon: Icon(
                              controller
                                      .obscureRegisterPasswordConfirmation.value
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _ProfileLaterNotice(),
                    const SizedBox(height: 20),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.isRegistering.value
                              ? null
                              : controller.register,
                          icon: controller.isRegistering.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1_rounded),
                          label: Text(
                            controller.isRegistering.value
                                ? 'Membuat akun...'
                                : 'Buat Akun',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton.icon(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text(
                    'Sudah punya akun? Masuk',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterHero extends StatelessWidget {
  const _RegisterHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.medical_services_rounded, color: Colors.white, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat akun pasien',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Isi data utama dulu. Alamat akan dilengkapi setelah akun dibuat.',
                  style: TextStyle(
                    color: Color(0xDFFFFFFF),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileLaterNotice extends StatelessWidget {
  const _ProfileLaterNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_location_alt_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Setelah akun dibuat, Anda akan diarahkan untuk melengkapi alamat pasien.',
              style: TextStyle(
                color: AppColors.lightMutedText,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/app_snackbar.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/data/models/auth_user_model.dart';

class AccountController extends GetxController {
  AccountController(this._storageService);

  final StorageService _storageService;

  final Rxn<AuthUserModel> user = Rxn<AuthUserModel>();
  final RxBool isSavingProfile = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool obscureCurrentPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final bloodTypeController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyContactPhoneController = TextEditingController();
  final allergiesController = TextEditingController();
  final medicalNotesController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    final userJson = _storageService.userJson;
    if (userJson == null) {
      user.value = null;
      return;
    }

    user.value = AuthUserModel.fromJson(userJson);
  }

  void prepareProfileForm() {
    final currentUser = user.value;
    final patient = currentUser?.patientProfile;

    nameController.text = currentUser?.name ?? '';
    emailController.text = currentUser?.email ?? '';
    phoneController.text = currentUser?.phone ?? '';
    dateOfBirthController.text = patient?.dateOfBirth ?? '';
    genderController.text = patient?.gender ?? '';
    addressController.text = patient?.address ?? '';
    bloodTypeController.text = patient?.bloodType ?? '';
    emergencyContactNameController.text = patient?.emergencyContactName ?? '';
    emergencyContactPhoneController.text = patient?.emergencyContactPhone ?? '';
    allergiesController.text = patient?.allergies ?? '';
    medicalNotesController.text = patient?.medicalNotes ?? '';
  }

  void preparePasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    obscureCurrentPassword.value = true;
    obscureNewPassword.value = true;
    obscureConfirmPassword.value = true;
  }

  Future<bool> saveProfile() async {
    final currentJson = _storageService.userJson;
    if (currentJson == null) {
      AppSnackbar.error('Gagal', 'Session akun tidak ditemukan.');
      return false;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      AppSnackbar.info('Validasi', 'Nama dan email wajib diisi.');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      AppSnackbar.info('Validasi', 'Format email belum valid.');
      return false;
    }

    isSavingProfile.value = true;

    try {
      final updatedJson = Map<String, dynamic>.from(currentJson);
      final patientJson = currentJson['patient_profile'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(
              currentJson['patient_profile'] as Map<String, dynamic>,
            )
          : <String, dynamic>{
              'id': 0,
              'user_id': updatedJson['id'] ?? 0,
              'created_at': DateTime.now().toIso8601String(),
            };
      final now = DateTime.now().toIso8601String();

      updatedJson
        ..['name'] = name
        ..['email'] = email
        ..['phone'] = phone
        ..['updated_at'] = now;

      patientJson
        ..['date_of_birth'] = dateOfBirthController.text.trim()
        ..['gender'] = genderController.text.trim()
        ..['address'] = addressController.text.trim()
        ..['blood_type'] = bloodTypeController.text.trim()
        ..['emergency_contact_name'] = emergencyContactNameController.text
            .trim()
        ..['emergency_contact_phone'] = emergencyContactPhoneController.text
            .trim()
        ..['allergies'] = allergiesController.text.trim()
        ..['medical_notes'] = medicalNotesController.text.trim()
        ..['updated_at'] = now;

      updatedJson['patient_profile'] = patientJson;

      await _storageService.saveUserJson(updatedJson);
      user.value = AuthUserModel.fromJson(updatedJson);
      AppSnackbar.success('Profil diperbarui', 'Data akun sudah tersimpan.');
      return true;
    } catch (_) {
      AppSnackbar.error('Gagal', 'Profil belum bisa disimpan.');
      return false;
    } finally {
      isSavingProfile.value = false;
    }
  }

  Future<bool> changePassword() async {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      AppSnackbar.info('Validasi', 'Semua field password wajib diisi.');
      return false;
    }

    if (newPassword.length < 8) {
      AppSnackbar.info('Validasi', 'Password baru minimal 8 karakter.');
      return false;
    }

    if (newPassword != confirmPassword) {
      AppSnackbar.info('Validasi', 'Konfirmasi password belum sama.');
      return false;
    }

    isChangingPassword.value = true;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      AppSnackbar.success(
        'Password diperbarui',
        'Password akun berhasil diperbarui.',
      );
      return true;
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();
    addressController.dispose();
    bloodTypeController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactPhoneController.dispose();
    allergiesController.dispose();
    medicalNotesController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../core/helpers/app_snackbar.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/usecases/register_use_case.dart';

class AuthController extends GetxController {
  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase;

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPhoneController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerPasswordConfirmationController = TextEditingController();
  final profileAddressController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isRegistering = false.obs;
  final RxBool isLoadingProvinces = false.obs;
  final RxBool isLoadingRegencies = false.obs;
  final RxBool isLoadingDistricts = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureRegisterPassword = true.obs;
  final RxBool obscureRegisterPasswordConfirmation = true.obs;
  final RxList<IndonesiaAreaOption> provinces = <IndonesiaAreaOption>[].obs;
  final RxList<IndonesiaAreaOption> regencies = <IndonesiaAreaOption>[].obs;
  final RxList<IndonesiaAreaOption> districts = <IndonesiaAreaOption>[].obs;
  final Rxn<IndonesiaAreaOption> selectedProvince = Rxn<IndonesiaAreaOption>();
  final Rxn<IndonesiaAreaOption> selectedRegency = Rxn<IndonesiaAreaOption>();
  final Rxn<IndonesiaAreaOption> selectedDistrict = Rxn<IndonesiaAreaOption>();

  final Dio _areaDio = Dio(
    BaseOptions(
      baseUrl: 'https://www.emsifa.com/api-wilayah-indonesia/api',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );

  @override
  void onInit() {
    super.onInit();
    loadProvinces();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRegisterPasswordVisibility() {
    obscureRegisterPassword.value = !obscureRegisterPassword.value;
  }

  void toggleRegisterPasswordConfirmationVisibility() {
    obscureRegisterPasswordConfirmation.value =
        !obscureRegisterPasswordConfirmation.value;
  }

  Future<void> loadProvinces() async {
    if (isLoadingProvinces.value || provinces.isNotEmpty) {
      return;
    }

    isLoadingProvinces.value = true;
    try {
      final response = await _areaDio.get<List<dynamic>>('/provinces.json');
      provinces.assignAll(_readAreaOptions(response.data));
    } catch (_) {
      AppSnackbar.error(
        'Wilayah gagal dimuat',
        'Daftar provinsi belum bisa dimuat. Coba lagi.',
      );
    } finally {
      isLoadingProvinces.value = false;
    }
  }

  Future<void> selectProvince(IndonesiaAreaOption? province) async {
    selectedProvince.value = province;
    selectedRegency.value = null;
    selectedDistrict.value = null;
    regencies.clear();
    districts.clear();

    if (province == null) {
      return;
    }

    isLoadingRegencies.value = true;
    try {
      final response = await _areaDio.get<List<dynamic>>(
        '/regencies/${province.id}.json',
      );
      regencies.assignAll(_readAreaOptions(response.data));
    } catch (_) {
      AppSnackbar.error(
        'Wilayah gagal dimuat',
        'Daftar kota/kabupaten belum bisa dimuat.',
      );
    } finally {
      isLoadingRegencies.value = false;
    }
  }

  Future<void> selectRegency(IndonesiaAreaOption? regency) async {
    selectedRegency.value = regency;
    selectedDistrict.value = null;
    districts.clear();

    if (regency == null) {
      return;
    }

    isLoadingDistricts.value = true;
    try {
      final response = await _areaDio.get<List<dynamic>>(
        '/districts/${regency.id}.json',
      );
      districts.assignAll(_readAreaOptions(response.data));
    } catch (_) {
      AppSnackbar.error(
        'Wilayah gagal dimuat',
        'Daftar kecamatan belum bisa dimuat.',
      );
    } finally {
      isLoadingDistricts.value = false;
    }
  }

  void selectDistrict(IndonesiaAreaOption? district) {
    selectedDistrict.value = district;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.info(
        'Validasi',
        'Email dan kata sandi wajib diisi.',
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

  Future<void> register() async {
    final name = registerNameController.text.trim();
    final email = registerEmailController.text.trim();
    final phone = registerPhoneController.text.trim();
    final password = registerPasswordController.text;
    final passwordConfirmation = registerPasswordConfirmationController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty) {
      AppSnackbar.info(
        'Validasi',
        'Nama, email, nomor HP, dan kata sandi wajib diisi.',
      );
      return;
    }

    if (password.length < 8) {
      AppSnackbar.info(
        'Kata sandi terlalu pendek',
        'Gunakan minimal 8 karakter.',
      );
      return;
    }

    if (password != passwordConfirmation) {
      AppSnackbar.info(
        'Kata sandi tidak sama',
        'Konfirmasi kata sandi harus sama dengan kata sandi.',
      );
      return;
    }

    isRegistering.value = true;

    try {
      final result = await _registerUseCase(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      AppSnackbar.success(
        'Akun siap',
        result.message.isEmpty ? 'Selamat datang di Perawatku.' : result.message,
      );

      _goToNextPageAfterAuth();
    } on AppException catch (error) {
      AppSnackbar.error(
        'Daftar gagal',
        error.message,
      );
    } catch (_) {
      AppSnackbar.error(
        'Daftar gagal',
        'Terjadi kesalahan tak terduga.',
      );
    } finally {
      isRegistering.value = false;
    }
  }

  Future<void> completeProfileAddress() async {
    final address = profileAddressController.text.trim();

    if (selectedProvince.value == null ||
        selectedRegency.value == null ||
        selectedDistrict.value == null ||
        address.isEmpty) {
      AppSnackbar.info(
        'Alamat belum lengkap',
        'Pilih provinsi, kota/kabupaten, kecamatan, dan isi alamat lengkap.',
      );
      return;
    }

    final storageService = Get.find<StorageService>();
    final userJson = storageService.userJson;
    if (userJson == null) {
      AppSnackbar.error('Session tidak ditemukan', 'Silakan login ulang.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final updatedJson = Map<String, dynamic>.from(userJson);
    final patientJson = userJson['patient_profile'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
            userJson['patient_profile'] as Map<String, dynamic>,
          )
        : <String, dynamic>{
            'id': 0,
            'user_id': updatedJson['id'] ?? 0,
            'created_at': DateTime.now().toIso8601String(),
          };
    final now = DateTime.now().toIso8601String();

    patientJson
      ..['address'] = _buildProfileAddress(address)
      ..['updated_at'] = now;
    updatedJson
      ..['patient_profile'] = patientJson
      ..['updated_at'] = now;

    await storageService.saveUserJson(updatedJson);
    AppSnackbar.success('Profil dilengkapi', 'Alamat pasien sudah tersimpan.');
    Get.offAllNamed(AppRoutes.home);
  }

  void _goToNextPageAfterAuth() {
    final storageService = Get.find<StorageService>();
    Get.offAllNamed(
      storageService.hasPatientAddress
          ? AppRoutes.home
          : AppRoutes.profileCompletion,
    );
  }

  String _buildProfileAddress(String address) {
    return [
      address,
      selectedDistrict.value?.name,
      selectedRegency.value?.name,
      selectedProvince.value?.name,
    ].whereType<String>().where((item) => item.trim().isNotEmpty).join(', ');
  }

  List<IndonesiaAreaOption> _readAreaOptions(List<dynamic>? source) {
    if (source == null) {
      return const <IndonesiaAreaOption>[];
    }

    final items = source
        .whereType<Map<String, dynamic>>()
        .map(IndonesiaAreaOption.fromJson)
        .toList();
    items.sort((first, second) => first.name.compareTo(second.name));
    return items;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    registerPasswordConfirmationController.dispose();
    profileAddressController.dispose();
    super.onClose();
  }
}

class IndonesiaAreaOption {
  const IndonesiaAreaOption({
    required this.id,
    required this.name,
  });

  factory IndonesiaAreaOption.fromJson(Map<String, dynamic> json) {
    return IndonesiaAreaOption(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
}

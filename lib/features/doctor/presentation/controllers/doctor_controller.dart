import 'package:get/get.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/usecases/get_doctors_use_case.dart';

class DoctorController extends GetxController {
  DoctorController(this._getDoctorsUseCase);

  final GetDoctorsUseCase _getDoctorsUseCase;

  final RxList<DoctorEntity> doctors = <DoctorEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }

  Future<void> loadDoctors({
    String? search,
    String? specialization,
    bool? isAvailable,
    int limit = 12,
    double? latitude,
    double? longitude,
    double? maxDistanceKm = 25,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _getDoctorsUseCase(
        search: search,
        specialization: specialization,
        isAvailable: isAvailable,
        limit: limit,
        latitude: latitude,
        longitude: longitude,
        maxDistanceKm: maxDistanceKm,
      );

      doctors.assignAll(result);
    } on AppException catch (error) {
      doctors.clear();
      errorMessage.value = error.message;
    } catch (_) {
      doctors.clear();
      errorMessage.value = 'Gagal memuat data dokter.';
    } finally {
      isLoading.value = false;
    }
  }
}

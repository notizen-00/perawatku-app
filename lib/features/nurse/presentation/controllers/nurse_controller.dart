import 'package:get/get.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/nurse_entity.dart';
import '../../domain/usecases/get_nurses_use_case.dart';

class NurseController extends GetxController {
  NurseController(this._getNursesUseCase);

  final GetNursesUseCase _getNursesUseCase;

  final RxList<NurseEntity> nurses = <NurseEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadNurses();
  }

  Future<void> loadNurses({
    String? search,
    String? specialization,
    bool? isAvailable,
    int limit = 10,
    double? latitude,
    double? longitude,
    double? maxDistanceKm = 25,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _getNursesUseCase(
        search: search,
        specialization: specialization,
        isAvailable: isAvailable,
        limit: limit,
        latitude: latitude,
        longitude: longitude,
        maxDistanceKm: maxDistanceKm,
      );

      nurses.assignAll(result);
    } on AppException catch (error) {
      nurses.clear();
      errorMessage.value = error.message;
    } catch (_) {
      nurses.clear();
      errorMessage.value = 'Gagal memuat data perawat.';
    } finally {
      isLoading.value = false;
    }
  }
}

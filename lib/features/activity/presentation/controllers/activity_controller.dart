import 'package:get/get.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/activity_record_entity.dart';
import '../../domain/usecases/get_consultation_activities_use_case.dart';
import '../../domain/usecases/get_medicine_purchase_activities_use_case.dart';
import '../../domain/usecases/get_other_activities_use_case.dart';

class ActivityController extends GetxController {
  ActivityController({
    required GetConsultationActivitiesUseCase getConsultationActivitiesUseCase,
    required GetMedicinePurchaseActivitiesUseCase
    getMedicinePurchaseActivitiesUseCase,
    required GetOtherActivitiesUseCase getOtherActivitiesUseCase,
  }) : _getConsultationActivitiesUseCase = getConsultationActivitiesUseCase,
       _getMedicinePurchaseActivitiesUseCase =
           getMedicinePurchaseActivitiesUseCase,
       _getOtherActivitiesUseCase = getOtherActivitiesUseCase;

  final GetConsultationActivitiesUseCase _getConsultationActivitiesUseCase;
  final GetMedicinePurchaseActivitiesUseCase
  _getMedicinePurchaseActivitiesUseCase;
  final GetOtherActivitiesUseCase _getOtherActivitiesUseCase;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<ActivityRecordEntity> consultationActivities =
      <ActivityRecordEntity>[].obs;
  final RxList<ActivityRecordEntity> medicineActivities =
      <ActivityRecordEntity>[].obs;
  final RxList<ActivityRecordEntity> otherActivities =
      <ActivityRecordEntity>[].obs;
  final RxnString dismissedActiveOrderKey = RxnString();

  ActivityRecordEntity? get activeOrder {
    final records = <ActivityRecordEntity>[
      ...consultationActivities,
      ...medicineActivities,
      ...otherActivities,
    ].where((record) => record.isActiveOrder).toList();

    if (records.isEmpty) {
      return null;
    }

    records.sort((first, second) {
      final firstTime =
          first.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final secondTime =
          second.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return secondTime.compareTo(firstTime);
    });

    return records.first;
  }

  ActivityRecordEntity? get visibleActiveOrder {
    final order = activeOrder;
    if (order == null) {
      return null;
    }

    if (_activeOrderKey(order) == dismissedActiveOrderKey.value) {
      return null;
    }

    return order;
  }

  @override
  void onInit() {
    super.onInit();
    loadActivities();
  }

  Future<void> loadActivities() async {
    isLoading.value = true;
    errorMessage.value = null;
    dismissedActiveOrderKey.value = null;

    try {
      final consultationResult = await _runSafely(
        _getConsultationActivitiesUseCase,
        onError: (message) => errorMessage.value = message,
      );
      final medicineResult = await _runSafely(
        _getMedicinePurchaseActivitiesUseCase,
      );
      final otherResult = await _runSafely(_getOtherActivitiesUseCase);

      consultationActivities.assignAll(consultationResult);
      medicineActivities.assignAll(medicineResult);
      otherActivities.assignAll(otherResult);
    } on AppException catch (error) {
      consultationActivities.clear();
      medicineActivities.clear();
      otherActivities.clear();
      errorMessage.value = error.message;
    } catch (_) {
      consultationActivities.clear();
      medicineActivities.clear();
      otherActivities.clear();
      errorMessage.value = 'Gagal memuat aktivitas pasien.';
    } finally {
      isLoading.value = false;
    }
  }

  void dismissActiveOrderOverlay() {
    final order = activeOrder;
    if (order == null) {
      return;
    }

    dismissedActiveOrderKey.value = _activeOrderKey(order);
  }

  String _activeOrderKey(ActivityRecordEntity order) {
    return '${order.category}:${order.id}:${order.status}';
  }

  Future<List<ActivityRecordEntity>> _runSafely(
    Future<List<ActivityRecordEntity>> Function() loader, {
    void Function(String message)? onError,
  }) async {
    try {
      return await loader();
    } on AppException catch (error) {
      onError?.call(error.message);
      return <ActivityRecordEntity>[];
    } catch (_) {
      onError?.call('Sebagian aktivitas belum bisa dimuat.');
      return <ActivityRecordEntity>[];
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/helpers/app_snackbar.dart';
import '../../../../core/services/midtrans_service.dart';
import '../../../activity/presentation/controllers/activity_controller.dart';
import '../../../patient_member/domain/entities/patient_member_entity.dart';
import '../../../patient_member/domain/usecases/get_patient_members_use_case.dart';
import '../../domain/entities/nurse_entity.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../../domain/entities/service_booking_service_entity.dart';
import '../../domain/usecases/check_promo_code_use_case.dart';
import '../../domain/usecases/create_service_booking_use_case.dart';
import '../../domain/usecases/get_service_booking_services_use_case.dart';
import '../../domain/usecases/get_service_booking_use_case.dart';
import '../../domain/usecases/get_nurses_use_case.dart';
import '../../domain/usecases/pay_service_booking_use_case.dart';

class NurseController extends GetxController {
  NurseController({
    required GetNursesUseCase getNursesUseCase,
    required GetServiceBookingServicesUseCase getServicesUseCase,
    required CreateServiceBookingUseCase createBookingUseCase,
    required GetServiceBookingUseCase getBookingUseCase,
    required PayServiceBookingUseCase payBookingUseCase,
    required CheckPromoCodeUseCase checkPromoCodeUseCase,
    required GetPatientMembersUseCase getPatientMembersUseCase,
    required MidtransService midtransService,
  }) : _getNursesUseCase = getNursesUseCase,
       _getServicesUseCase = getServicesUseCase,
       _createBookingUseCase = createBookingUseCase,
       _getBookingUseCase = getBookingUseCase,
       _payBookingUseCase = payBookingUseCase,
       _checkPromoCodeUseCase = checkPromoCodeUseCase,
       _getPatientMembersUseCase = getPatientMembersUseCase,
       _midtransService = midtransService;

  final GetNursesUseCase _getNursesUseCase;
  final GetServiceBookingServicesUseCase _getServicesUseCase;
  final CreateServiceBookingUseCase _createBookingUseCase;
  final GetServiceBookingUseCase _getBookingUseCase;
  final PayServiceBookingUseCase _payBookingUseCase;
  final CheckPromoCodeUseCase _checkPromoCodeUseCase;
  final GetPatientMembersUseCase _getPatientMembersUseCase;
  final MidtransService _midtransService;

  final RxList<NurseEntity> nurses = <NurseEntity>[].obs;
  final RxList<ServiceBookingServiceEntity> services =
      <ServiceBookingServiceEntity>[].obs;
  final RxList<PatientMemberEntity> patientMembers =
      <PatientMemberEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingServices = false.obs;
  final RxBool isLoadingMembers = false.obs;
  final RxBool isCreatingBooking = false.obs;
  final RxBool isRefreshingBooking = false.obs;
  final RxBool isOpeningPayment = false.obs;
  final RxBool isCheckingPromo = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString serviceErrorMessage = RxnString();
  final RxnString memberErrorMessage = RxnString();
  final RxnString promoStatusMessage = RxnString();
  final RxBool isPromoValid = false.obs;
  final RxnString selectedServiceCategoryKey = RxnString();
  final Rxn<ServiceBookingServiceEntity> selectedService =
      Rxn<ServiceBookingServiceEntity>();
  final Rxn<PatientMemberEntity> selectedPatientMember =
      Rxn<PatientMemberEntity>();
  final Rxn<ServiceBookingEntity> latestBooking = Rxn<ServiceBookingEntity>();

  final TextEditingController notesController = TextEditingController();
  final TextEditingController scheduledAtController = TextEditingController();
  final TextEditingController promoCodeController = TextEditingController();

  bool get isMidtransReady =>
      _midtransService.isSupportedPlatform && _midtransService.isConfigured;

  @override
  void onInit() {
    super.onInit();
    loadNurses();
    loadServices();
    loadPatientMembers();
    _midtransService.setTransactionFinishedCallback(_handlePaymentFinished);
  }

  @override
  void onClose() {
    notesController.dispose();
    scheduledAtController.dispose();
    promoCodeController.dispose();
    _midtransService.removeTransactionFinishedCallback();
    super.onClose();
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

  Future<void> loadServices({
    String? search,
    String category = '',
  }) async {
    isLoadingServices.value = true;
    serviceErrorMessage.value = null;

    try {
      var result = await _getServicesUseCase(
        category: category.isEmpty ? null : category,
        search: search,
        perPage: 100,
      );

      if (result.isEmpty && category.isNotEmpty) {
        result = await _getServicesUseCase(search: search, perPage: 100);
      }

      services.assignAll(result);
      _syncServiceCategoryAfterLoad();
      final filtered = filteredServices;
      final currentService = selectedService.value;
      if (result.isEmpty) {
        selectedService.value = null;
      } else if (currentService == null ||
          !filtered.any(
            (service) =>
                service.bookingServiceId == currentService.bookingServiceId,
          )) {
        selectedService.value = filtered.isEmpty ? null : filtered.first;
      }
    } on AppException catch (error) {
      services.clear();
      serviceErrorMessage.value = error.message;
    } catch (_) {
      services.clear();
      serviceErrorMessage.value = 'Gagal memuat katalog layanan.';
    } finally {
      isLoadingServices.value = false;
    }
  }

  void selectService(ServiceBookingServiceEntity service) {
    selectedServiceCategoryKey.value = serviceCategoryKey(service);
    selectedService.value = service;
    promoStatusMessage.value = null;
    isPromoValid.value = false;
  }

  bool selectServiceByBookingServiceId(int serviceId) {
    for (final service in services) {
      if (service.bookingServiceId == serviceId) {
        selectService(service);
        return true;
      }
    }

    return false;
  }

  List<ServiceCategoryOption> get serviceCategories {
    final options = <String, ServiceCategoryOption>{};

    for (final service in services) {
      final key = serviceCategoryKey(service);
      options.putIfAbsent(
        key,
        () => ServiceCategoryOption(
          key: key,
          id: service.categoryId,
          name: serviceCategoryName(service),
          icon: service.categoryIcon,
        ),
      );
    }

    final result = options.values.toList();
    result.sort((first, second) => first.name.compareTo(second.name));
    return result;
  }

  ServiceCategoryOption? get selectedServiceCategory {
    final categories = serviceCategories;
    if (categories.isEmpty) {
      return null;
    }

    final selectedKey = selectedServiceCategoryKey.value;
    for (final category in categories) {
      if (category.key == selectedKey) {
        return category;
      }
    }

    return categories.first;
  }

  List<ServiceBookingServiceEntity> get filteredServices {
    final category = selectedServiceCategory;
    if (category == null) {
      return const <ServiceBookingServiceEntity>[];
    }

    return services
        .where((service) => serviceCategoryKey(service) == category.key)
        .toList();
  }

  void selectServiceCategory(ServiceCategoryOption? category) {
    if (category == null) {
      return;
    }

    selectedServiceCategoryKey.value = category.key;
    final filtered = filteredServices;
    selectedService.value = filtered.isEmpty ? null : filtered.first;
    promoStatusMessage.value = null;
    isPromoValid.value = false;
  }

  Future<void> loadPatientMembers() async {
    isLoadingMembers.value = true;
    memberErrorMessage.value = null;

    try {
      final result = await _getPatientMembersUseCase(perPage: 100);
      patientMembers.assignAll(result);

      final primary = result.where((member) => member.isPrimary);
      selectedPatientMember.value = primary.isNotEmpty
          ? primary.first
          : result.isEmpty
              ? null
              : result.first;
      await _reloadNursesForSelectedMember();
    } on AppException catch (error) {
      patientMembers.clear();
      selectedPatientMember.value = null;
      memberErrorMessage.value = error.message;
    } catch (_) {
      patientMembers.clear();
      selectedPatientMember.value = null;
      memberErrorMessage.value = 'Gagal memuat profil pasien keluarga.';
    } finally {
      isLoadingMembers.value = false;
    }
  }

  Future<void> selectPatientMember(PatientMemberEntity? member) async {
    selectedPatientMember.value = member;
    await _reloadNursesForSelectedMember();
  }

  Future<void> pickScheduledAt(DateTime date, TimeOfDay time) async {
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    scheduledAtController.text = _formatDateTimeForBackend(scheduledAt);
  }

  Future<void> checkPromoCode() async {
    final service = selectedService.value;
    final code = promoCodeController.text.trim();

    if (service == null) {
      AppSnackbar.info('Pilih layanan', 'Pilih layanan sebelum cek promo.');
      return;
    }

    if (code.isEmpty) {
      promoStatusMessage.value = null;
      isPromoValid.value = false;
      AppSnackbar.info('Kode promo kosong', 'Isi kode promo terlebih dahulu.');
      return;
    }

    isCheckingPromo.value = true;
    promoStatusMessage.value = null;
    isPromoValid.value = false;

    try {
      final response = await _checkPromoCodeUseCase(
        code: code,
        serviceId: service.bookingServiceId,
      );
      final message = response['message']?.toString();
      isPromoValid.value = true;
      promoStatusMessage.value = message?.isNotEmpty == true
          ? message
          : 'Kode promo valid dan bisa dipakai.';
      AppSnackbar.success('Promo valid', promoStatusMessage.value!);
    } on AppException catch (error) {
      promoStatusMessage.value = error.message;
      AppSnackbar.error('Promo tidak valid', error.message);
    } catch (_) {
      promoStatusMessage.value = 'Kode promo belum bisa dicek.';
      AppSnackbar.error('Promo tidak valid', 'Kode promo belum bisa dicek.');
    } finally {
      isCheckingPromo.value = false;
    }
  }

  NurseEntity? get nearestNurse {
    final available = nurses.where((nurse) => nurse.distanceKm != null).toList();
    if (available.isEmpty) {
      return nurses.isEmpty ? null : nurses.first;
    }

    available.sort((first, second) {
      return first.distanceKm!.compareTo(second.distanceKm!);
    });
    return available.first;
  }

  Future<void> createBooking() async {
    final service = selectedService.value;
    final patientMember = selectedPatientMember.value;

    if (service == null) {
      AppSnackbar.info(
        'Pilih layanan',
        'Pilih layanan homecare dari katalog backend terlebih dahulu.',
      );
      return;
    }

    if (service.bookingServiceId <= 0) {
      AppSnackbar.error(
        'Layanan tidak valid',
        'ID layanan dari katalog backend kosong. Muat ulang katalog layanan.',
      );
      return;
    }

    if (patientMember == null) {
      AppSnackbar.info(
        'Pilih profil pasien',
        'Pilih profil pasien keluarga yang akan menerima layanan.',
      );
      return;
    }

    isCreatingBooking.value = true;

    try {
      final booking = await _createBookingUseCase(
        serviceId: service.bookingServiceId,
        patientMemberId: patientMember.id,
        scheduledAt: scheduledAtController.text,
        notes: notesController.text,
        promoCode: promoCodeController.text,
      );
      latestBooking.value = booking;
      _refreshActivities();

      AppSnackbar.success(
        'Booking dibuat',
        'Matchmaking berhasil dibuat. Selesaikan pembayaran agar pesanan bisa diproses.',
      );

      if (booking.isPaid) {
        return;
      }

      await openLatestBookingPayment();
    } on AppException catch (error) {
      AppSnackbar.error('Booking gagal', error.message);
    } catch (_) {
      AppSnackbar.error(
        'Booking gagal',
        'Tidak bisa membuat booking layanan saat ini.',
      );
    } finally {
      isCreatingBooking.value = false;
    }
  }

  Future<void> openLatestBookingPayment() async {
    var booking = latestBooking.value;

    if (booking == null) {
      AppSnackbar.info('Booking belum ada', 'Buat booking terlebih dahulu.');
      return;
    }

    if (booking.isPaid) {
      AppSnackbar.success(
        'Pembayaran sudah selesai',
        'Pesanan sudah bisa diproses oleh mitra.',
      );
      return;
    }

    if (!_midtransService.isSupportedPlatform) {
      AppSnackbar.info(
        'Midtrans tidak tersedia',
        'Pembayaran Midtrans hanya berjalan di Android atau iOS.',
      );
      return;
    }

    if (!_midtransService.isConfigured) {
      AppSnackbar.error(
        'Midtrans belum aktif',
        'Isi MIDTRANS_CLIENT_KEY terlebih dulu agar pembayaran bisa dipakai.',
      );
      return;
    }

    isOpeningPayment.value = true;

    try {
      if (booking.snapToken == null || booking.snapToken!.isEmpty) {
        booking = await _payBookingUseCase(
          booking.id,
          notes: notesController.text,
        );
        latestBooking.value = booking;
      }

      final snapToken = booking.snapToken;
      if (snapToken == null || snapToken.isEmpty) {
        AppSnackbar.info(
          'Token pembayaran belum tersedia',
          'Backend belum mengirim snap token untuk booking ini.',
        );
        return;
      }

      await _midtransService.startPayment(snapToken: snapToken);
      await refreshLatestBooking(showSuccessWhenPaid: false);
    } on AppException catch (error) {
      AppSnackbar.error('Pembayaran gagal', error.message);
    } catch (_) {
      AppSnackbar.error(
        'Pembayaran gagal',
        'Tidak bisa membuka halaman pembayaran Midtrans.',
      );
    } finally {
      isOpeningPayment.value = false;
    }
  }

  Future<void> refreshLatestBooking({bool showSuccessWhenPaid = true}) async {
    final bookingId = latestBooking.value?.id;
    if (bookingId == null || bookingId == 0) {
      return;
    }

    isRefreshingBooking.value = true;

    try {
      final booking = await _getBookingUseCase(bookingId);
      latestBooking.value = booking;
      _refreshActivities();

      if (booking.isPaid && showSuccessWhenPaid) {
        AppSnackbar.success(
          'Pembayaran terverifikasi',
          'Pesanan sudah bisa diproses oleh mitra.',
        );
      } else if (!booking.isPaid && showSuccessWhenPaid) {
        AppSnackbar.info(
          'Masih menunggu pembayaran',
          'Selesaikan pembayaran dulu sebelum pesanan diproses.',
        );
      }
    } on AppException catch (error) {
      AppSnackbar.error('Refresh gagal', error.message);
    } catch (_) {
      AppSnackbar.error(
        'Refresh gagal',
        'Status booking belum bisa diperbarui.',
      );
    } finally {
      isRefreshingBooking.value = false;
    }
  }

  Future<void> _handlePaymentFinished(TransactionResult result) async {
    final status = result.status.toLowerCase();

    if (status == 'settlement' || status == 'capture') {
      AppSnackbar.success(
        'Pembayaran berhasil',
        'Pesanan akan diproses setelah status backend terverifikasi.',
      );
    } else if (status == 'pending') {
      AppSnackbar.info(
        'Pembayaran tertunda',
        'Status booking akan berubah setelah pembayaran masuk.',
      );
    } else if (status == 'cancel' || status == 'deny' || status == 'expire') {
      AppSnackbar.error(
        'Pembayaran belum selesai',
        result.message ?? 'Silakan coba lagi dengan metode pembayaran lain.',
      );
    }

    await refreshLatestBooking(showSuccessWhenPaid: true);
  }

  void _refreshActivities() {
    if (Get.isRegistered<ActivityController>()) {
      Get.find<ActivityController>().loadActivities();
    }
  }

  Future<void> _reloadNursesForSelectedMember() {
    final member = selectedPatientMember.value;
    return loadNurses(
      latitude: member?.latitude,
      longitude: member?.longitude,
      maxDistanceKm: member?.latitude == null || member?.longitude == null
          ? null
          : 25,
    );
  }

  String _formatDateTimeForBackend(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  void _syncServiceCategoryAfterLoad() {
    if (services.isEmpty) {
      selectedServiceCategoryKey.value = null;
      return;
    }

    final selectedKey = selectedServiceCategoryKey.value;
    final stillExists = selectedKey != null &&
        services.any((service) => serviceCategoryKey(service) == selectedKey);

    if (!stillExists) {
      selectedServiceCategoryKey.value = serviceCategoryKey(services.first);
    }
  }

  String serviceCategoryKey(ServiceBookingServiceEntity service) {
    final categoryId = service.categoryId;
    if (categoryId != null && categoryId > 0) {
      return categoryId.toString();
    }

    return serviceCategoryName(service).toLowerCase();
  }

  String serviceCategoryName(ServiceBookingServiceEntity service) {
    final raw = service.categoryName ?? service.category ?? 'Lainnya';
    final trimmed = raw.trim();
    return trimmed.isEmpty ? 'Lainnya' : trimmed;
  }
}

class ServiceCategoryOption {
  const ServiceCategoryOption({
    required this.key,
    required this.id,
    required this.name,
    required this.icon,
  });

  final String key;
  final int? id;
  final String name;
  final String? icon;
}

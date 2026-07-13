import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/helpers/app_snackbar.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/midtrans_service.dart';
import '../../../activity/presentation/controllers/activity_controller.dart';
import '../../../nurse/domain/entities/nurse_entity.dart';
import '../../../nurse/domain/usecases/get_nurses_use_case.dart';
import '../../../patient_member/domain/entities/patient_member_entity.dart';
import '../../../patient_member/domain/usecases/get_patient_members_use_case.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../../domain/entities/service_booking_service_entity.dart';
import '../../domain/usecases/cancel_service_booking_use_case.dart';
import '../../domain/usecases/check_promo_code_use_case.dart';
import '../../domain/usecases/confirm_service_booking_completion_use_case.dart';
import '../../domain/usecases/create_service_booking_use_case.dart';
import '../../domain/usecases/get_service_booking_services_use_case.dart';
import '../../domain/usecases/get_service_booking_use_case.dart';
import '../../domain/usecases/pay_service_booking_use_case.dart';

class ServiceBookingController extends GetxController {
  ServiceBookingController({
    required GetNursesUseCase getNursesUseCase,
    required GetServiceBookingServicesUseCase getServicesUseCase,
    required CreateServiceBookingUseCase createBookingUseCase,
    required GetServiceBookingUseCase getBookingUseCase,
    required PayServiceBookingUseCase payBookingUseCase,
    required ConfirmServiceBookingCompletionUseCase confirmCompletionUseCase,
    required CancelServiceBookingUseCase cancelBookingUseCase,
    required CheckPromoCodeUseCase checkPromoCodeUseCase,
    required GetPatientMembersUseCase getPatientMembersUseCase,
    required MidtransService midtransService,
  }) : _getNursesUseCase = getNursesUseCase,
       _getServicesUseCase = getServicesUseCase,
       _createBookingUseCase = createBookingUseCase,
       _getBookingUseCase = getBookingUseCase,
       _payBookingUseCase = payBookingUseCase,
       _confirmCompletionUseCase = confirmCompletionUseCase,
       _cancelBookingUseCase = cancelBookingUseCase,
       _checkPromoCodeUseCase = checkPromoCodeUseCase,
       _getPatientMembersUseCase = getPatientMembersUseCase,
       _midtransService = midtransService;

  final GetNursesUseCase _getNursesUseCase;
  final GetServiceBookingServicesUseCase _getServicesUseCase;
  final CreateServiceBookingUseCase _createBookingUseCase;
  final GetServiceBookingUseCase _getBookingUseCase;
  final PayServiceBookingUseCase _payBookingUseCase;
  final ConfirmServiceBookingCompletionUseCase _confirmCompletionUseCase;
  final CancelServiceBookingUseCase _cancelBookingUseCase;
  final CheckPromoCodeUseCase _checkPromoCodeUseCase;
  final GetPatientMembersUseCase _getPatientMembersUseCase;
  final MidtransService _midtransService;

  final RxList<NurseEntity> nurses = <NurseEntity>[].obs;
  final RxList<ServiceBookingServiceEntity> services =
      <ServiceBookingServiceEntity>[].obs;
  final RxList<ServiceCategoryOption> serviceCategoryOptions =
      <ServiceCategoryOption>[].obs;
  final RxList<PatientMemberEntity> patientMembers =
      <PatientMemberEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingServices = false.obs;
  final RxBool isLoadingCategoryServices = false.obs;
  final RxBool isLoadingMembers = false.obs;
  final RxBool isCreatingBooking = false.obs;
  final RxBool isLoadingBookingDetail = false.obs;
  final RxBool isRefreshingBooking = false.obs;
  final RxBool isOpeningPayment = false.obs;
  final RxBool isConfirmingCompletion = false.obs;
  final RxBool isCancellingBooking = false.obs;
  final RxBool isLivePollingBookingDetail = false.obs;
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
  final Rxn<ServiceBookingEntity> bookingDetail = Rxn<ServiceBookingEntity>();
  final RxnString bookingDetailErrorMessage = RxnString();

  final TextEditingController notesController = TextEditingController();
  final TextEditingController scheduledAtController = TextEditingController();
  final TextEditingController visitCountController = TextEditingController(
    text: '4',
  );
  final TextEditingController promoCodeController = TextEditingController();
  final RxString selectedScheduleOption = ServiceScheduleOption.once.obs;
  final RxString selectedCareMode = ServiceCareMode.visit.obs;
  final RxString selectedLocationType = ServiceBookingLocationType.home.obs;

  int _categoryCatalogRequestId = 0;
  int _categoryServicesRequestId = 0;
  bool _isRefreshingServiceCatalog = false;
  Timer? _bookingDetailPollingTimer;
  final Map<String, List<ServiceBookingServiceEntity>> _servicesByCategoryKey =
      {};

  bool get isMidtransReady =>
      _midtransService.isSupportedPlatform && _midtransService.isConfigured;

  @override
  void onInit() {
    super.onInit();
    _logServiceState('onInit');
    loadNurses();
    loadServiceCategories();
    loadPatientMembers();
    _midtransService.setTransactionFinishedCallback(_handlePaymentFinished);
  }

  @override
  void onClose() {
    notesController.dispose();
    scheduledAtController.dispose();
    visitCountController.dispose();
    promoCodeController.dispose();
    _midtransService.removeTransactionFinishedCallback();
    stopBookingDetailPolling();
    super.onClose();
  }

  Future<void> resetMatchmakingForm({bool reloadCatalog = true}) async {
    _logServiceState('resetMatchmakingForm:start reloadCatalog=$reloadCatalog');
    _categoryCatalogRequestId++;
    _categoryServicesRequestId++;
    selectedServiceCategoryKey.value = null;
    selectedService.value = null;
    services.clear();
    _servicesByCategoryKey.clear();
    latestBooking.value = null;
    bookingDetail.value = null;
    serviceErrorMessage.value = null;
    promoStatusMessage.value = null;
    isPromoValid.value = false;
    notesController.clear();
    scheduledAtController.clear();
    visitCountController.text = '4';
    promoCodeController.clear();
    selectedScheduleOption.value = ServiceScheduleOption.once;
    selectedCareMode.value = ServiceCareMode.visit;
    selectedLocationType.value = ServiceBookingLocationType.home;

    if (reloadCatalog) {
      await loadServiceCategories();
    }
    _logServiceState('resetMatchmakingForm:done');
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

  Future<void> refreshServiceCatalog() async {
    if (_isRefreshingServiceCatalog) {
      return;
    }

    _isRefreshingServiceCatalog = true;
    try {
      await loadServiceCategories(
        keepSelectedCategory: true,
        reloadSelectedCategoryServices: true,
      );
    } finally {
      _isRefreshingServiceCatalog = false;
    }
  }

  Future<void> loadServiceCategories({
    String? search,
    bool keepSelectedCategory = false,
    bool reloadSelectedCategoryServices = false,
  }) async {
    final requestId = ++_categoryCatalogRequestId;
    _logServiceState(
      'loadServiceCategories:start requestId=$requestId '
      'keepSelected=$keepSelectedCategory reloadSelected=$reloadSelectedCategoryServices',
    );
    isLoadingServices.value = true;
    serviceErrorMessage.value = null;

    try {
      final result = await _getServicesUseCase(search: search, perPage: 100);
      if (requestId != _categoryCatalogRequestId) {
        return;
      }

      final categories = _buildServiceCategoryOptions(result);
      final selectedKey = selectedServiceCategoryKey.value;
      serviceCategoryOptions.assignAll(categories);
      _logServiceState(
        'loadServiceCategories:success requestId=$requestId '
        'rawServices=${result.length} categories=${categories.length}',
      );

      final canKeepSelectedCategory =
          keepSelectedCategory &&
          selectedKey != null &&
          categories.any((category) => category.key == selectedKey);

      if (!canKeepSelectedCategory) {
        selectedServiceCategoryKey.value = null;
        services.clear();
        selectedService.value = null;
        _logServiceState('loadServiceCategories:clearedSelection');
        return;
      }

      if (reloadSelectedCategoryServices) {
        final category = categories.firstWhere(
          (category) => category.key == selectedKey,
        );
        await loadServices(
          categoryId: category.id,
          category: category.name,
          selectFirstService: selectedService.value == null,
        );
      }
    } on AppException catch (error) {
      if (requestId != _categoryCatalogRequestId) {
        return;
      }
      services.clear();
      serviceCategoryOptions.clear();
      serviceErrorMessage.value = error.message;
      _logServiceState(
        'loadServiceCategories:appError requestId=$requestId message=${error.message}',
      );
    } catch (_) {
      if (requestId != _categoryCatalogRequestId) {
        return;
      }
      services.clear();
      serviceCategoryOptions.clear();
      serviceErrorMessage.value = 'Gagal memuat katalog layanan.';
      _logServiceState('loadServiceCategories:error requestId=$requestId');
    } finally {
      if (requestId == _categoryCatalogRequestId) {
        isLoadingServices.value = false;
        _logServiceState('loadServiceCategories:done requestId=$requestId');
      }
    }
  }

  Future<void> loadServices({
    String? search,
    String category = '',
    int? categoryId,
    bool selectFirstService = false,
  }) async {
    if (category.trim().isEmpty && (categoryId == null || categoryId <= 0)) {
      await loadServiceCategories(search: search);
      return;
    }

    final requestId = ++_categoryServicesRequestId;
    final requestedCategoryKey = _categoryKeyFromRequest(
      categoryId: categoryId,
      category: category,
    );
    _logServiceState(
      'loadServices:start requestId=$requestId categoryKey=$requestedCategoryKey '
      'categoryId=$categoryId category="$category" selectFirst=$selectFirstService',
    );
    isLoadingCategoryServices.value = true;
    serviceErrorMessage.value = null;

    try {
      var result = await _getServicesUseCase(
        categoryId: categoryId,
        category: (categoryId == null || categoryId <= 0) && category.isNotEmpty
            ? category
            : null,
        search: search,
        perPage: 100,
      );

      if (result.isEmpty && categoryId != null && categoryId > 0) {
        _logServiceState(
          'loadServices:fallbackByName requestId=$requestId category="$category"',
        );
        result = await _getServicesUseCase(
          category: category.isEmpty ? null : category,
          search: search,
          perPage: 100,
        );
      }

      if (requestId != _categoryServicesRequestId ||
          selectedServiceCategoryKey.value != requestedCategoryKey) {
        _logServiceState(
          'loadServices:ignored requestId=$requestId latest=$_categoryServicesRequestId '
          'selectedKey=${selectedServiceCategoryKey.value} requestedKey=$requestedCategoryKey '
          'result=${result.length}',
        );
        return;
      }

      _servicesByCategoryKey[requestedCategoryKey] = result;
      final currentServiceId = selectedService.value?.bookingServiceId;
      final currentService = result.where(
        (service) => service.bookingServiceId == currentServiceId,
      );
      final nextSelectedService = selectFirstService
          ? (result.isEmpty ? null : result.first)
          : currentService.isEmpty
          ? null
          : currentService.first;
      selectedService.value = nextSelectedService;
      if (nextSelectedService != null) {
        _normalizeScheduleForSelectedService(nextSelectedService);
      }
      services.assignAll(result);
      if (serviceCategoryOptions.isEmpty) {
        serviceCategoryOptions.assignAll(_buildServiceCategoryOptions(result));
      }
      _logServiceState(
        'loadServices:assigned requestId=$requestId result=${result.length}',
      );
    } on AppException catch (error) {
      if (requestId != _categoryServicesRequestId) {
        return;
      }
      services.clear();
      selectedService.value = null;
      serviceErrorMessage.value = error.message;
      _logServiceState(
        'loadServices:appError requestId=$requestId message=${error.message}',
      );
    } catch (_) {
      if (requestId != _categoryServicesRequestId) {
        return;
      }
      services.clear();
      selectedService.value = null;
      serviceErrorMessage.value = 'Gagal memuat katalog layanan.';
      _logServiceState('loadServices:error requestId=$requestId');
    } finally {
      if (requestId == _categoryServicesRequestId) {
        isLoadingCategoryServices.value = false;
        _logServiceState('loadServices:done requestId=$requestId');
      }
    }
  }

  void selectService(ServiceBookingServiceEntity service) {
    selectedServiceCategoryKey.value = serviceCategoryKey(service);
    selectedService.value = service;
    promoStatusMessage.value = null;
    isPromoValid.value = false;
    _normalizeScheduleForSelectedService(service);
    _logServiceState(
      'selectService serviceId=${service.bookingServiceId} name="${service.name}"',
    );
  }

  void primeSelectedService(ServiceBookingServiceEntity service) {
    final key = serviceCategoryKey(service);
    selectedServiceCategoryKey.value = key;
    selectedService.value = service;
    promoStatusMessage.value = null;
    isPromoValid.value = false;
    _normalizeScheduleForSelectedService(service);

    final cached = _servicesByCategoryKey[key] ?? <ServiceBookingServiceEntity>[];
    final hasService = cached.any(
      (item) => item.bookingServiceId == service.bookingServiceId,
    );
    if (!hasService) {
      _servicesByCategoryKey[key] = <ServiceBookingServiceEntity>[
        service,
        ...cached,
      ];
    }

    if (services.every(
      (item) => item.bookingServiceId != service.bookingServiceId,
    )) {
      services.assignAll(<ServiceBookingServiceEntity>[service, ...services]);
    }

    if (serviceCategoryOptions.every((category) => category.key != key)) {
      serviceCategoryOptions.add(
        ServiceCategoryOption(
          key: key,
          id: service.categoryId,
          name: serviceCategoryName(service),
          icon: service.categoryIcon,
        ),
      );
      serviceCategoryOptions.sort((first, second) {
        return first.name.compareTo(second.name);
      });
    }

    _logServiceState(
      'primeSelectedService serviceId=${service.bookingServiceId} name="${service.name}"',
    );
  }

  Future<bool> selectServiceByBookingServiceId(int serviceId) async {
    for (final service in services) {
      if (service.bookingServiceId == serviceId) {
        selectService(service);
        return true;
      }
    }

    try {
      final result = await _getServicesUseCase(perPage: 100);
      serviceCategoryOptions.assignAll(_buildServiceCategoryOptions(result));
      for (final service in result) {
        if (service.bookingServiceId == serviceId) {
          primeSelectedService(service);
          await loadServices(
            categoryId: service.categoryId,
            category: serviceCategoryName(service),
          );
          for (final categoryService in services) {
            if (categoryService.bookingServiceId == serviceId) {
              selectService(categoryService);
              return true;
            }
          }
          primeSelectedService(service);
          return true;
        }
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  List<ServiceCategoryOption> get serviceCategories {
    if (serviceCategoryOptions.isNotEmpty) {
      return serviceCategoryOptions.toList();
    }

    return _buildServiceCategoryOptions(services);
  }

  List<ServiceCategoryOption> _buildServiceCategoryOptions(
    Iterable<ServiceBookingServiceEntity> source,
  ) {
    final options = <String, ServiceCategoryOption>{};

    for (final service in source) {
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
    if (selectedKey == null) {
      return null;
    }

    for (final category in categories) {
      if (category.key == selectedKey) {
        return category;
      }
    }

    return null;
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

  Future<void> selectServiceCategory(ServiceCategoryOption? category) async {
    if (category == null) {
      _logServiceState('selectServiceCategory:null');
      return;
    }

    _logServiceState(
      'selectServiceCategory:start key=${category.key} id=${category.id} '
      'name="${category.name}"',
    );
    _categoryServicesRequestId++;
    selectedServiceCategoryKey.value = category.key;
    final cachedServices =
        _servicesByCategoryKey[category.key] ??
        const <ServiceBookingServiceEntity>[];
    if (cachedServices.isNotEmpty) {
      services.assignAll(cachedServices);
      selectedService.value = cachedServices.first;
      _normalizeScheduleForSelectedService(cachedServices.first);
      _logServiceState(
        'selectServiceCategory:useCache count=${cachedServices.length}',
      );
    } else {
      selectedService.value = null;
      services.clear();
      _logServiceState('selectServiceCategory:noCache clearServices');
    }
    promoStatusMessage.value = null;
    isPromoValid.value = false;
    await loadServices(
      categoryId: category.id,
      category: category.name,
      selectFirstService: true,
    );
    _logServiceState('selectServiceCategory:done key=${category.key}');
  }

  Future<void> reloadSelectedCategoryServices() async {
    final category = selectedServiceCategory;
    if (category == null) {
      await loadServiceCategories();
      return;
    }

    await loadServices(
      categoryId: category.id,
      category: category.name,
      selectFirstService: true,
    );
  }

  Future<void> loadPatientMembers() async {
    isLoadingMembers.value = true;
    memberErrorMessage.value = null;

    try {
      final result = await _getPatientMembersUseCase(perPage: 100);
      patientMembers.assignAll(result);

      final currentMemberId = selectedPatientMember.value?.id;
      final currentMember = result.where(
        (member) => member.id == currentMemberId,
      );
      final primary = result.where((member) => member.isPrimary);
      selectedPatientMember.value = currentMember.isNotEmpty
          ? currentMember.first
          : primary.isNotEmpty
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

  void selectScheduleOption(String option) {
    final service = selectedService.value;
    final nextOption = option == ServiceScheduleOption.once ||
            service == null ||
            serviceSupportsRecurringSchedule(service)
        ? option
        : ServiceScheduleOption.once;
    selectedScheduleOption.value = nextOption;
    if (nextOption == ServiceScheduleOption.once) {
      selectedCareMode.value = ServiceCareMode.visit;
    }
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
    final available = nurses
        .where((nurse) => nurse.distanceKm != null)
        .toList();
    if (available.isEmpty) {
      return nurses.isEmpty ? null : nurses.first;
    }

    available.sort((first, second) {
      return first.distanceKm!.compareTo(second.distanceKm!);
    });
    return available.first;
  }

  Future<ServiceBookingEntity?> createBooking() async {
    final service = selectedService.value;
    final patientMember = selectedPatientMember.value;

    if (service == null) {
      AppSnackbar.info(
        'Pilih layanan',
        'Pilih layanan homecare dari katalog backend terlebih dahulu.',
      );
      return null;
    }

    if (service.bookingServiceId <= 0) {
      AppSnackbar.error(
        'Layanan tidak valid',
        'ID layanan dari katalog backend kosong. Muat ulang katalog layanan.',
      );
      return null;
    }

    if (patientMember == null) {
      AppSnackbar.info(
        'Pilih profil pasien',
        'Pilih profil pasien keluarga yang akan menerima layanan.',
      );
      return null;
    }

    if (scheduledAtController.text.trim().isEmpty) {
      AppSnackbar.info(
        'Pilih tanggal kunjungan',
        'Tentukan jadwal sebelum membuat booking layanan ini.',
      );
      return null;
    }

    final visitCount = _readVisitCount();
    if (isRecurringSchedule && (visitCount == null || visitCount < 2)) {
      AppSnackbar.info(
        'Jumlah kunjungan belum valid',
        'Isi minimal 2 kunjungan untuk jadwal mingguan atau bulanan.',
      );
      return null;
    }

    if (isRecurringSchedule && visitCount != null && visitCount > 52) {
      AppSnackbar.info(
        'Jumlah kunjungan terlalu banyak',
        'Maksimal 52 kunjungan untuk jadwal mingguan atau bulanan.',
      );
      return null;
    }

    isCreatingBooking.value = true;

    try {
      final booking = await _createBookingUseCase(
        serviceId: service.bookingServiceId,
        patientMemberId: patientMember.id,
        scheduledAt: scheduledAtController.text,
        visitPlan: isRecurringSchedule ? 'recurring' : 'once',
        recurrence: isRecurringSchedule ? selectedScheduleOption.value : null,
        visitCount: isRecurringSchedule ? visitCount : null,
        careMode: selectedCareMode.value,
        locationType: selectedLocationType.value,
        notes: notesController.text,
        promoCode: promoCodeController.text,
      );
      latestBooking.value = booking;
      _refreshActivities();

      AppSnackbar.success(
        'Booking dibuat',
        'Detail booking sedang dibuka.',
      );
      return booking;
    } on AppException catch (error) {
      AppSnackbar.error('Booking gagal', error.message);
      return null;
    } catch (_) {
      AppSnackbar.error(
        'Booking gagal',
        'Tidak bisa membuat booking layanan saat ini.',
      );
      return null;
    } finally {
      isCreatingBooking.value = false;
    }
  }

  Future<void> openLatestBookingDetail() async {
    final booking = latestBooking.value;
    if (booking == null) {
      AppSnackbar.info('Booking belum ada', 'Buat booking terlebih dahulu.');
      return;
    }

    await Get.toNamed(
      AppRoutes.serviceBookingDetail,
      arguments: {
        'bookingId': booking.id,
        'booking': booking,
        'serviceName': selectedService.value?.name,
        'patientName': selectedPatientMember.value?.name,
      },
    );
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

  Future<void> loadBookingDetail(int bookingId) async {
    if (bookingId <= 0) {
      bookingDetail.value = null;
      bookingDetailErrorMessage.value = 'Booking tidak valid.';
      return;
    }

    isLoadingBookingDetail.value = true;
    bookingDetailErrorMessage.value = null;

    try {
      final booking = await _getBookingUseCase(bookingId);
      bookingDetail.value = booking;
      latestBooking.value = booking;
      _refreshActivities();
    } on AppException catch (error) {
      bookingDetailErrorMessage.value = error.message;
    } catch (_) {
      bookingDetailErrorMessage.value = 'Detail booking belum bisa dimuat.';
    } finally {
      isLoadingBookingDetail.value = false;
    }
  }

  void startBookingDetailPolling(int bookingId) {
    if (bookingId <= 0) {
      return;
    }

    isLivePollingBookingDetail.value = true;
    _bookingDetailPollingTimer?.cancel();
    _bookingDetailPollingTimer = Timer.periodic(const Duration(seconds: 12), (
      _,
    ) async {
      final current = bookingDetail.value;
      if (current != null &&
          ((current.isCompleted &&
                  !current.needsPatientCompletionConfirmation) ||
              current.status.toLowerCase().trim() == 'cancelled')) {
        stopBookingDetailPolling();
        return;
      }

      await loadBookingDetailSilently(bookingId);
    });
  }

  void stopBookingDetailPolling() {
    _bookingDetailPollingTimer?.cancel();
    _bookingDetailPollingTimer = null;
    isLivePollingBookingDetail.value = false;
  }

  Future<void> loadBookingDetailSilently(int bookingId) async {
    if (bookingId <= 0 || isLoadingBookingDetail.value) {
      return;
    }

    try {
      final booking = await _getBookingUseCase(bookingId);
      bookingDetail.value = booking;
      latestBooking.value = booking;
      _refreshActivities();
    } catch (_) {
      // Polling realtime tidak perlu mengganggu UI dengan snackbar.
    }
  }

  Future<void> confirmBookingCompletion(int bookingId, {String? notes}) async {
    if (bookingId <= 0) {
      AppSnackbar.error('Booking tidak valid', 'Detail booking tidak lengkap.');
      return;
    }

    isConfirmingCompletion.value = true;

    try {
      final booking = await _confirmCompletionUseCase(bookingId, notes: notes);
      bookingDetail.value = booking;
      latestBooking.value = booking;
      _refreshActivities();
      AppSnackbar.success(
        'Layanan dikonfirmasi',
        'Saldo layanan sudah diproses ke mitra.',
      );
    } on AppException catch (error) {
      AppSnackbar.error('Konfirmasi gagal', error.message);
    } catch (_) {
      AppSnackbar.error(
        'Konfirmasi gagal',
        'Status selesai belum bisa dikonfirmasi saat ini.',
      );
    } finally {
      isConfirmingCompletion.value = false;
    }
  }

  Future<void> cancelBooking(int bookingId, {String? reason}) async {
    if (bookingId <= 0) {
      AppSnackbar.error('Booking tidak valid', 'Detail booking tidak lengkap.');
      return;
    }

    final booking = bookingDetail.value ?? latestBooking.value;
    if (booking != null && !booking.canCancelBeforePartnerFound) {
      AppSnackbar.info(
        'Tidak bisa dibatalkan',
        'Booking sudah dibayar, diterima mitra, atau sedang berjalan.',
      );
      return;
    }

    isCancellingBooking.value = true;

    try {
      final cancelled = await _cancelBookingUseCase(bookingId, reason: reason);
      bookingDetail.value = cancelled;
      latestBooking.value = cancelled;
      stopBookingDetailPolling();
      _refreshActivities();
      AppSnackbar.success('Booking dibatalkan', 'Pesanan berhasil dibatalkan.');
    } on AppException catch (error) {
      AppSnackbar.error('Batal gagal', error.message);
    } catch (_) {
      AppSnackbar.error(
        'Batal gagal',
        'Endpoint pembatalan booking belum tersedia atau sedang bermasalah.',
      );
    } finally {
      isCancellingBooking.value = false;
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

  bool get isRecurringSchedule {
    final option = selectedScheduleOption.value;
    return option == ServiceScheduleOption.weekly ||
        option == ServiceScheduleOption.monthly;
  }

  bool get selectedServiceSupportsRecurringSchedule {
    final service = selectedService.value;
    return service != null && serviceSupportsRecurringSchedule(service);
  }

  bool serviceSupportsRecurringSchedule(ServiceBookingServiceEntity service) {
    final haystack = [
      service.name,
      service.category,
      service.categoryName,
      service.serviceType,
      service.serviceMode,
      service.description,
    ].whereType<String>().join(' ').toLowerCase();

    return haystack.contains('caregiver') ||
        haystack.contains('care giver') ||
        haystack.contains('pendamping') ||
        haystack.contains('harian') ||
        haystack.contains('live-in') ||
        haystack.contains('live in');
  }

  void _normalizeScheduleForSelectedService(ServiceBookingServiceEntity service) {
    if (!serviceSupportsRecurringSchedule(service) && isRecurringSchedule) {
      selectedScheduleOption.value = ServiceScheduleOption.once;
      selectedCareMode.value = ServiceCareMode.visit;
      return;
    }

    if (!isRecurringSchedule) {
      selectedCareMode.value = ServiceCareMode.visit;
    }
  }

  int? _readVisitCount() {
    return int.tryParse(visitCountController.text.trim());
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

  String _categoryKeyFromRequest({int? categoryId, required String category}) {
    if (categoryId != null && categoryId > 0) {
      return categoryId.toString();
    }

    final trimmed = category.trim();
    return trimmed.isEmpty ? 'lainnya' : trimmed.toLowerCase();
  }

  void _logServiceState(String event) {
    debugPrint(
      '[ServiceBookingController] $event | '
      'selectedCategoryKey=${selectedServiceCategoryKey.value} '
      'selectedServiceId=${selectedService.value?.bookingServiceId} '
      'selectedServiceName="${selectedService.value?.name}" '
      'services=${services.length} categories=${serviceCategoryOptions.length} '
      'cacheKeys=${_servicesByCategoryKey.keys.join(',')} '
      'isLoadingServices=${isLoadingServices.value} '
      'isLoadingCategoryServices=${isLoadingCategoryServices.value} '
      'serviceError="${serviceErrorMessage.value}"',
    );
  }
}

class ServiceScheduleOption {
  const ServiceScheduleOption._();

  static const String once = 'once';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
}

class ServiceCareMode {
  const ServiceCareMode._();

  static const String visit = 'visit';
  static const String liveIn = 'live_in';
}

class ServiceBookingLocationType {
  const ServiceBookingLocationType._();

  static const String home = 'home';
  static const String hospital = 'hospital';
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

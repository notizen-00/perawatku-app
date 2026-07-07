import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/helpers/app_snackbar.dart';
import '../../../../core/services/midtrans_service.dart';
import '../../../activity/presentation/controllers/activity_controller.dart';
import '../../domain/entities/nurse_entity.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../../domain/entities/service_booking_service_entity.dart';
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
    required MidtransService midtransService,
  }) : _getNursesUseCase = getNursesUseCase,
       _getServicesUseCase = getServicesUseCase,
       _createBookingUseCase = createBookingUseCase,
       _getBookingUseCase = getBookingUseCase,
       _payBookingUseCase = payBookingUseCase,
       _midtransService = midtransService;

  final GetNursesUseCase _getNursesUseCase;
  final GetServiceBookingServicesUseCase _getServicesUseCase;
  final CreateServiceBookingUseCase _createBookingUseCase;
  final GetServiceBookingUseCase _getBookingUseCase;
  final PayServiceBookingUseCase _payBookingUseCase;
  final MidtransService _midtransService;

  final RxList<NurseEntity> nurses = <NurseEntity>[].obs;
  final RxList<ServiceBookingServiceEntity> services =
      <ServiceBookingServiceEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingServices = false.obs;
  final RxBool isCreatingBooking = false.obs;
  final RxBool isRefreshingBooking = false.obs;
  final RxBool isOpeningPayment = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString serviceErrorMessage = RxnString();
  final Rxn<ServiceBookingServiceEntity> selectedService =
      Rxn<ServiceBookingServiceEntity>();
  final Rxn<ServiceBookingEntity> latestBooking = Rxn<ServiceBookingEntity>();

  final TextEditingController patientAddressIdController =
      TextEditingController();
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
    _midtransService.setTransactionFinishedCallback(_handlePaymentFinished);
  }

  @override
  void onClose() {
    patientAddressIdController.dispose();
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
    String category = 'perawat_homecare',
  }) async {
    isLoadingServices.value = true;
    serviceErrorMessage.value = null;

    try {
      var result = await _getServicesUseCase(
        category: category,
        search: search,
        perPage: 20,
      );

      if (result.isEmpty && category.isNotEmpty) {
        result = await _getServicesUseCase(search: search, perPage: 20);
      }

      services.assignAll(result);
      final currentService = selectedService.value;
      if (result.isEmpty) {
        selectedService.value = null;
      } else if (currentService == null ||
          !result.any((service) => service.id == currentService.id)) {
        selectedService.value = result.first;
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
    selectedService.value = service;
  }

  Future<void> createBooking() async {
    final service = selectedService.value;
    final patientAddressId = int.tryParse(
      patientAddressIdController.text.trim(),
    );

    if (service == null) {
      AppSnackbar.info(
        'Pilih layanan',
        'Pilih layanan homecare dari katalog backend terlebih dahulu.',
      );
      return;
    }

    if (patientAddressId == null || patientAddressId <= 0) {
      AppSnackbar.info(
        'Alamat dibutuhkan',
        'Isi ID alamat pasien agar backend bisa menjalankan matchmaking jarak.',
      );
      return;
    }

    isCreatingBooking.value = true;

    try {
      final booking = await _createBookingUseCase(
        serviceId: service.id,
        patientAddressId: patientAddressId,
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
}

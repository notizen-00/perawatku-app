import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/midtrans_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../map/domain/entities/navigation_route.dart';
import '../../../map/domain/usecases/get_partner_locations_use_case.dart';
import '../../../nurse/domain/usecases/get_nurses_use_case.dart';
import '../../../patient_member/domain/usecases/get_patient_members_use_case.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../../domain/usecases/cancel_service_booking_use_case.dart';
import '../../domain/usecases/check_promo_code_use_case.dart';
import '../../domain/usecases/confirm_service_booking_completion_use_case.dart';
import '../../domain/usecases/create_service_booking_use_case.dart';
import '../../domain/usecases/get_service_booking_services_use_case.dart';
import '../../domain/usecases/get_service_booking_use_case.dart';
import '../../domain/usecases/pay_service_booking_use_case.dart';
import '../../domain/usecases/rematch_service_booking_use_case.dart';
import '../controllers/service_booking_controller.dart';
import '../widgets/inline_error.dart';

class ServiceBookingDetailPage extends StatefulWidget {
  const ServiceBookingDetailPage({super.key});

  @override
  State<ServiceBookingDetailPage> createState() =>
      _ServiceBookingDetailPageState();
}

class _ServiceBookingDetailPageState extends State<ServiceBookingDetailPage> {
  late final ServiceBookingController controller;
  late final _ServiceBookingDetailArguments arguments;
  late final GetNavigationRouteUseCase _getNavigationRouteUseCase;
  final MapController _trackingMapController = MapController();
  final RxBool _isLoadingRoute = false.obs;
  final RxList<LatLng> _routePoints = <LatLng>[].obs;
  final RxDouble _routeDistanceMeters = 0.0.obs;
  final RxDouble _routeDurationSeconds = 0.0.obs;
  final RxnString _routeErrorMessage = RxnString();
  Worker? _bookingDetailWorker;

  @override
  void initState() {
    super.initState();
    controller = _ensureController();
    arguments = _ServiceBookingDetailArguments.from(Get.arguments);
    _getNavigationRouteUseCase = Get.find<GetNavigationRouteUseCase>();
    _bookingDetailWorker = ever<ServiceBookingEntity?>(
      controller.bookingDetail,
      (booking) {
        _syncTrackingRoute(booking);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialBooking = arguments.booking;
      if (initialBooking != null) {
        controller.bookingDetail.value = initialBooking;
        controller.latestBooking.value = initialBooking;
      }
      controller.loadBookingDetail(arguments.bookingId);
      controller.startBookingDetailPolling(arguments.bookingId);
    });
  }

  @override
  void dispose() {
    _bookingDetailWorker?.dispose();
    controller.stopBookingDetailPolling();
    _trackingMapController.dispose();
    super.dispose();
  }

  ServiceBookingController _ensureController() {
    if (Get.isRegistered<ServiceBookingController>()) {
      return Get.find<ServiceBookingController>();
    }

    return Get.put(
      ServiceBookingController(
        getNursesUseCase: Get.find<GetNursesUseCase>(),
        getServicesUseCase: Get.find<GetServiceBookingServicesUseCase>(),
        createBookingUseCase: Get.find<CreateServiceBookingUseCase>(),
        getBookingUseCase: Get.find<GetServiceBookingUseCase>(),
        payBookingUseCase: Get.find<PayServiceBookingUseCase>(),
        rematchBookingUseCase: Get.find<RematchServiceBookingUseCase>(),
        confirmCompletionUseCase:
            Get.find<ConfirmServiceBookingCompletionUseCase>(),
        cancelBookingUseCase: Get.find<CancelServiceBookingUseCase>(),
        checkPromoCodeUseCase: Get.find<CheckPromoCodeUseCase>(),
        getPatientMembersUseCase: Get.find<GetPatientMembersUseCase>(),
        midtransService: Get.find<MidtransService>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() {
        final booking = controller.bookingDetail.value ?? arguments.booking;
        final error = controller.bookingDetailErrorMessage.value;

        if (controller.isLoadingBookingDetail.value && booking == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && booking == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: InlineError(
                message: error,
                onRetry: () =>
                    controller.loadBookingDetail(arguments.bookingId),
              ),
            ),
          );
        }

        if (booking == null) {
          return const Center(child: Text('Detail pesanan belum tersedia.'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadBookingDetail(arguments.bookingId),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 330,
                collapsedHeight: 86,
                toolbarHeight: 70,
                pinned: true,
                stretch: true,
                backgroundColor: isDark
                    ? const Color(0xFF0F1F1D)
                    : const Color(0xFFF5F7F7),
                foregroundColor: isDark ? Colors.white : Colors.black87,
                title: Text(
                  booking.bookingCode,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                actions: [
                  Obx(() {
                    if (_needsPayment(booking)) {
                      return _PulsingPayAction(
                        isLoading: controller.isOpeningPayment.value,
                        onPressed: controller.isOpeningPayment.value
                            ? null
                            : () => _payBookingFromHeader(booking),
                      );
                    }

                    return TextButton.icon(
                      onPressed:
                          booking.canCancelBeforePartnerFound &&
                              !controller.isCancellingBooking.value
                          ? () => _confirmCancelBooking(booking)
                          : null,
                      icon: controller.isCancellingBooking.value
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.close_rounded),
                      label: const Text('Batal'),
                    );
                  }),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _PremiumMapPreview(
                    booking: booking,
                    mapController: _trackingMapController,
                    routePoints: _routePoints,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _PremiumBookingExperience(
                      booking: booking,
                      serviceName:
                          booking.serviceName ?? arguments.serviceName ?? '-',
                      isDark: isDark,
                      isLoadingRoute: _isLoadingRoute,
                      routeDistanceMeters: _routeDistanceMeters,
                      routeDurationSeconds: _routeDurationSeconds,
                      routeErrorMessage: _routeErrorMessage,
                      isLivePolling: controller.isLivePollingBookingDetail,
                      isConfirmingCompletion: controller.isConfirmingCompletion,
                      isOpeningPayment: controller.isOpeningPayment,
                      isRematchingPartner: controller.isRematchingPartner,
                      isLoadingBookingDetail: controller.isLoadingBookingDetail,
                      onRefreshRoute: () => _loadTrackingRoute(booking),
                      onRefreshDetail: () =>
                          controller.loadBookingDetail(arguments.bookingId),
                      onOpenDetail: () => _openOrderDetail(booking),
                      onPay: () async {
                        controller.latestBooking.value = booking;
                        await controller.openLatestBookingPayment();
                        await controller.loadBookingDetail(arguments.bookingId);
                      },
                      onRematch: () => controller.requestPartnerRematch(booking),
                      onConfirmCompletion: () => controller
                          .confirmBookingCompletion(arguments.bookingId),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _confirmCancelBooking(ServiceBookingEntity booking) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Batalkan pesanan?'),
        content: const Text(
          'Pesanan yang belum dibayar dan belum diterima mitra bisa dibatalkan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.cancelBooking(
        booking.id,
        reason: 'Dibatalkan oleh pasien sebelum dibayar dan diterima mitra.',
      );
    }
  }

  bool _needsPayment(ServiceBookingEntity booking) {
    return booking.isAcceptedByPartner && !booking.isPaid;
  }

  Future<void> _payBookingFromHeader(ServiceBookingEntity booking) async {
    controller.latestBooking.value = booking;
    await controller.openLatestBookingPayment();
    await controller.loadBookingDetail(arguments.bookingId);
  }

  Future<void> _openOrderDetail(ServiceBookingEntity booking) async {
    await Get.toNamed(
      AppRoutes.serviceBookingOrderDetail,
      arguments: {
        'bookingId': booking.id,
        'booking': booking,
        'serviceName': booking.serviceName ?? arguments.serviceName,
        'patientName': booking.patientMemberName ?? arguments.patientName,
      },
    );
  }

  Future<void> _syncTrackingRoute(ServiceBookingEntity? booking) async {
    if (booking == null ||
        !booking.isOnTheWay ||
        !booking.hasTrackingCoordinates) {
      _routePoints.clear();
      _routeDistanceMeters.value = 0;
      _routeDurationSeconds.value = 0;
      _routeErrorMessage.value = null;
      return;
    }

    await _loadTrackingRoute(booking);
  }

  Future<void> _loadTrackingRoute(ServiceBookingEntity booking) async {
    if (!booking.hasTrackingCoordinates || _isLoadingRoute.value) {
      return;
    }

    _isLoadingRoute.value = true;
    _routeErrorMessage.value = null;

    try {
      final route = await _getNavigationRouteUseCase.execute(
        originLatitude: booking.partnerLatitude!,
        originLongitude: booking.partnerLongitude!,
        destinationLatitude: booking.patientLatitude!,
        destinationLongitude: booking.patientLongitude!,
      );
      _applyRoute(route, booking);
    } catch (_) {
      _routeErrorMessage.value = 'Rute belum bisa dimuat.';
    } finally {
      _isLoadingRoute.value = false;
    }
  }

  void _applyRoute(NavigationRoute route, ServiceBookingEntity booking) {
    _routePoints.assignAll(route.points);
    _routeDistanceMeters.value = route.distanceMeters;
    _routeDurationSeconds.value = route.durationSeconds;

    final center = LatLng(
      (booking.partnerLatitude! + booking.patientLatitude!) / 2,
      (booking.partnerLongitude! + booking.patientLongitude!) / 2,
    );
    final zoom = _zoomForDistance(route.distanceMeters);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _trackingMapController.move(center, zoom);
      } catch (_) {}
    });
  }

  double _zoomForDistance(double meters) {
    if (meters < 1000) {
      return 15.5;
    }
    if (meters < 3000) {
      return 14;
    }
    if (meters < 8000) {
      return 13;
    }
    return 11.5;
  }
}

class ServiceBookingOrderDetailPage extends StatefulWidget {
  const ServiceBookingOrderDetailPage({super.key});

  @override
  State<ServiceBookingOrderDetailPage> createState() =>
      _ServiceBookingOrderDetailPageState();
}

class _PulsingPayAction extends StatefulWidget {
  const _PulsingPayAction({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  State<_PulsingPayAction> createState() => _PulsingPayActionState();
}

class _PulsingPayActionState extends State<_PulsingPayAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FilledButton.icon(
        onPressed: widget.onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(0, 38),
        ),
        icon: widget.isLoading
            ? const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.payments_rounded, size: 18),
        label: const Text(
          'Bayar',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ServiceBookingOrderDetailPageState
    extends State<ServiceBookingOrderDetailPage> {
  late final ServiceBookingController controller;
  late final _ServiceBookingDetailArguments arguments;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ServiceBookingController>();
    arguments = _ServiceBookingDetailArguments.from(Get.arguments);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialBooking = arguments.booking;
      if (initialBooking != null) {
        controller.bookingDetail.value = initialBooking;
        controller.latestBooking.value = initialBooking;
      }
      controller.loadBookingDetail(arguments.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isLoadingBookingDetail.value
                  ? null
                  : () => controller.loadBookingDetail(arguments.bookingId),
              icon: controller.isLoadingBookingDetail.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final booking = controller.bookingDetail.value ?? arguments.booking;
        final error = controller.bookingDetailErrorMessage.value;

        if (controller.isLoadingBookingDetail.value && booking == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && booking == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: InlineError(
                message: error,
                onRetry: () =>
                    controller.loadBookingDetail(arguments.bookingId),
              ),
            ),
          );
        }

        if (booking == null) {
          return const Center(child: Text('Detail pesanan belum tersedia.'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _DetailSection(
              title: 'Detail Pesanan',
              icon: Icons.medical_services_rounded,
              rows: [
                _DetailRow(label: 'Kode pesanan', value: booking.bookingCode),
                _DetailRow(label: 'Nomor pesanan', value: booking.id.toString()),
                _DetailRow(
                  label: 'Nama layanan',
                  value: booking.serviceName ?? arguments.serviceName ?? '-',
                ),
                _DetailRow(
                  label: 'Nomor layanan',
                  value: booking.serviceId?.toString() ?? '-',
                ),
                _DetailRow(label: 'Status', value: booking.status),
                _DetailRow(
                  label: 'Jadwal',
                  value: _formatDateTime(booking.scheduledAt),
                ),
                _DetailRow(
                  label: 'Diterima',
                  value: _formatDateTime(booking.acceptedAt),
                ),
                _DetailRow(
                  label: 'Mulai jalan',
                  value: _formatDateTime(booking.startedAt),
                ),
                _DetailRow(
                  label: 'Selesai',
                  value: _formatDateTime(booking.completedAt),
                ),
                _DetailRow(label: 'Catatan', value: booking.notes ?? '-'),
              ],
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _DetailSection(
              title: 'Pasien & Mitra',
              icon: Icons.group_rounded,
              rows: [
                _DetailRow(
                  label: 'Pasien',
                  value:
                      booking.patientMemberName ?? arguments.patientName ?? '-',
                ),
                _DetailRow(
                  label: 'Nomor pasien',
                  value: booking.patientMemberId?.toString() ?? '-',
                ),
                _DetailRow(
                  label: 'Mitra',
                  value: booking.isAcceptedByPartner
                      ? booking.partnerName ??
                            (booking.assignedPartnerUserId == null
                                ? '-'
                                : '#${booking.assignedPartnerUserId}')
                      : booking.isSearchingReplacementPartner
                      ? 'Sedang mencari mitra'
                      : 'Menunggu konfirmasi mitra',
                ),
                _DetailRow(
                  label: 'Alamat pasien',
                  value: booking.patientAddressId == null
                      ? '-'
                      : '#${booking.patientAddressId}',
                ),
                _DetailRow(
                  label: 'Koordinat pasien',
                  value: _formatCoordinate(
                    booking.patientLatitude,
                    booking.patientLongitude,
                  ),
                ),
                _DetailRow(
                  label: 'Nomor mitra',
                  value: booking.assignedPartnerUserId?.toString() ?? '-',
                ),
                _DetailRow(
                  label: 'Koordinat mitra',
                  value: _formatCoordinate(
                    booking.partnerLatitude,
                    booking.partnerLongitude,
                  ),
                ),
              ],
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _DetailSection(
              title: 'Pembayaran',
              icon: Icons.payments_rounded,
              rows: [
                _DetailRow(
                  label: 'Subtotal',
                  value: CurrencyFormatter.formatRupiahFromString(
                    booking.subtotal,
                    emptyValue: '-',
                  ),
                ),
                _DetailRow(
                  label: 'Diskon',
                  value: CurrencyFormatter.formatRupiahFromString(
                    booking.discountAmount,
                    emptyValue: '-',
                  ),
                ),
                _DetailRow(
                  label: 'Transportasi',
                  value: CurrencyFormatter.formatRupiahFromString(
                    booking.transportFee,
                    emptyValue: '-',
                  ),
                ),
                _DetailRow(
                  label: 'Uang makan',
                  value: CurrencyFormatter.formatRupiahFromString(
                    booking.mealFee,
                    emptyValue: '-',
                  ),
                ),
                _DetailRow(
                  label: 'Biaya tambahan',
                  value: CurrencyFormatter.formatRupiahFromString(
                    booking.extraFeeTotal,
                    emptyValue: '-',
                  ),
                ),
                _DetailRow(
                  label: 'Total',
                  value: CurrencyFormatter.formatRupiahFromString(
                    booking.totalAmount,
                    emptyValue: '-',
                  ),
                ),
                _DetailRow(label: 'Jadwal', value: _formatVisitPlan(booking)),
                _DetailRow(
                  label: 'Jarak biaya',
                  value: booking.distanceKm == null
                      ? '-'
                      : '${booking.distanceKm!.toStringAsFixed(1)} km',
                ),
                _DetailRow(
                  label: 'Status bayar',
                  value: booking.paymentStatus ?? 'pending',
                ),
                if ((booking.paymentReference ?? '').trim().isNotEmpty)
                  _DetailRow(
                    label: 'Kode pembayaran',
                    value: booking.paymentReference ?? '-',
                  ),
              ],
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            if (booking.extraFeeApplied || booking.feeMessages.isNotEmpty) ...[
              _FeeMessageSection(booking: booking, isDark: isDark),
              const SizedBox(height: 12),
            ],
          ],
        );
      }),
    );
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatCoordinate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return '-';
    }

    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String _formatVisitPlan(ServiceBookingEntity booking) {
    final visitPlan = booking.visitPlan ?? '-';
    final recurrence = booking.recurrence;
    final visitCount = booking.visitCount;
    if (visitPlan == '-' || visitPlan == 'once') {
      return 'Sekali kunjungan';
    }

    final parts = <String>['Berulang'];
    if (recurrence != null && recurrence.trim().isNotEmpty) {
      parts.add(recurrence == 'monthly' ? 'bulanan' : 'mingguan');
    }
    if (visitCount != null) {
      parts.add('$visitCount kunjungan');
    }
    return parts.join(' - ');
  }
}

class _PremiumBookingExperience extends StatelessWidget {
  const _PremiumBookingExperience({
    required this.booking,
    required this.serviceName,
    required this.isDark,
    required this.isLoadingRoute,
    required this.routeDistanceMeters,
    required this.routeDurationSeconds,
    required this.routeErrorMessage,
    required this.isLivePolling,
    required this.isConfirmingCompletion,
    required this.isOpeningPayment,
    required this.isRematchingPartner,
    required this.isLoadingBookingDetail,
    required this.onRefreshRoute,
    required this.onRefreshDetail,
    required this.onOpenDetail,
    required this.onPay,
    required this.onRematch,
    required this.onConfirmCompletion,
  });

  final ServiceBookingEntity booking;
  final String serviceName;
  final bool isDark;
  final RxBool isLoadingRoute;
  final RxDouble routeDistanceMeters;
  final RxDouble routeDurationSeconds;
  final RxnString routeErrorMessage;
  final RxBool isLivePolling;
  final RxBool isConfirmingCompletion;
  final RxBool isOpeningPayment;
  final RxBool isRematchingPartner;
  final RxBool isLoadingBookingDetail;
  final VoidCallback onRefreshRoute;
  final VoidCallback onRefreshDetail;
  final VoidCallback onOpenDetail;
  final VoidCallback onPay;
  final VoidCallback onRematch;
  final VoidCallback onConfirmCompletion;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1F1D) : const Color(0xFFF5F7F7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE6ECEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _panelTitle(booking),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              _panelSubtitle(
                                booking,
                                routeDurationSeconds.value,
                              ),
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkMutedText
                                    : AppColors.lightMutedText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => _StatusPill(
                        label: isLivePolling.value ? 'Aktif' : booking.status,
                        color: isLivePolling.value
                            ? AppColors.success
                            : AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _PremiumTimeline(
                  booking: booking,
                  distanceMeters: routeDistanceMeters,
                ),
                Obx(
                  () => routeErrorMessage.value == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            routeErrorMessage.value!,
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ),
                if (booking.isOnTheWay) ...[
                  const SizedBox(height: 10),
                  Obx(
                    () => OutlinedButton.icon(
                      onPressed: isLoadingRoute.value ? null : onRefreshRoute,
                      icon: isLoadingRoute.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: const Text('Perbarui rute'),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _PremiumPartnerCard(
                  booking: booking,
                  serviceName: serviceName,
                  isConfirmingCompletion: isConfirmingCompletion,
                  onConfirmCompletion: onConfirmCompletion,
                ),
                const SizedBox(height: 14),
                _PricingBreakdownCard(booking: booking, isDark: isDark),
                const SizedBox(height: 14),
                _PrimaryTrackingActions(
                  booking: booking,
                  isOpeningPayment: isOpeningPayment,
                  isRematchingPartner: isRematchingPartner,
                  isLoadingBookingDetail: isLoadingBookingDetail,
                  onOpenDetail: onOpenDetail,
                  onRefreshDetail: onRefreshDetail,
                  onPay: onPay,
                  onRematch: onRematch,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(double seconds) {
    if (seconds <= 0) {
      return '-';
    }
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) {
      return '$minutes mins';
    }
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours hr' : '$hours hr $rest mins';
  }

  static String _panelTitle(ServiceBookingEntity booking) {
    final status = booking.status.toLowerCase().trim();
    if (status == 'completed') {
      return 'Layanan Selesai';
    }
    if (status == 'cancelled') {
      return 'Pesanan Dibatalkan';
    }
    if (booking.isOnTheWay) {
      return 'Pelacakan aktif';
    }
    if (status == 'confirmed' || status == 'scheduled') {
      return 'Mitra Disiapkan';
    }
    if (booking.canRequestPartnerRematch) {
      return 'Mitra Belum Tersedia';
    }
    if (booking.isSearchingReplacementPartner) {
      return 'Mencari Mitra';
    }
    if (booking.isWaitingPartnerAcceptance) {
      return 'Menunggu Mitra';
    }
    return 'Menunggu Mitra';
  }

  static String _panelSubtitle(ServiceBookingEntity booking, double seconds) {
    final status = booking.status.toLowerCase().trim();
    if (booking.isOnTheWay) {
      return 'Estimated arrival in ${_formatDuration(seconds)}';
    }
    if (status == 'completed') {
      return booking.partnerBalanceTransactionId == null
          ? 'Konfirmasi selesai agar saldo mitra diproses.'
          : 'Saldo mitra sudah diproses.';
    }
    if (status == 'cancelled') {
      return 'Pesanan ini sudah tidak aktif.';
    }
    if (status == 'confirmed' || status == 'scheduled') {
      return 'Map aktif saat mitra mulai menuju lokasi.';
    }
    if (booking.canRequestPartnerRematch) {
      return 'Belum ada mitra pengganti yang tersedia. Anda bisa coba cari mitra lagi.';
    }
    if (booking.isSearchingReplacementPartner) {
      return 'Mitra sebelumnya belum menerima. Sistem mencari pengganti.';
    }
    if (booking.isWaitingPartnerAcceptance) {
      return 'Menunggu mitra menerima pesanan sebelum pembayaran.';
    }
    return 'Kami mencari mitra yang sesuai untuk pesanan ini.';
  }
}

class _PricingBreakdownCard extends StatelessWidget {
  const _PricingBreakdownCard({required this.booking, required this.isDark});

  final ServiceBookingEntity booking;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE3ECE8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Ringkasan biaya',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                _money(booking.totalAmount),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PricingLine(label: 'Subtotal', value: _money(booking.subtotal)),
          _PricingLine(label: 'Diskon', value: _money(booking.discountAmount)),
          _PricingLine(
            label: 'Transportasi',
            value: _money(booking.transportFee),
          ),
          _PricingLine(label: 'Uang makan', value: _money(booking.mealFee)),
          if (booking.extraFeeApplied || booking.extraFeeTotal != null)
            _PricingLine(
              label: 'Biaya tambahan',
              value: _money(booking.extraFeeTotal),
            ),
          if (booking.feeMessages.isNotEmpty) ...[
            const SizedBox(height: 10),
            _FeeMessageList(messages: booking.feeMessages, isDark: isDark),
          ],
          if (booking.distanceKm != null || booking.visitCount != null) ...[
            const SizedBox(height: 8),
            Text(
              _feeNote(booking),
              style: TextStyle(
                color: isDark
                    ? AppColors.darkMutedText
                    : AppColors.lightMutedText,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _money(String? amount) {
    return CurrencyFormatter.formatRupiahFromString(amount, emptyValue: '-');
  }

  static String _feeNote(ServiceBookingEntity booking) {
    final notes = <String>[];
    if (booking.visitCount != null) {
      notes.add('${booking.visitCount} kunjungan');
    }
    if (booking.distanceKm != null) {
      notes.add('jarak ${booking.distanceKm!.toStringAsFixed(1)} km');
    }
    if (booking.careMode == 'live_in') {
      notes.add('menginap');
    }
    return notes.join(' - ');
  }
}

class _PricingLine extends StatelessWidget {
  const _PricingLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkMutedText
                    : AppColors.lightMutedText,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _FeeMessageSection extends StatelessWidget {
  const _FeeMessageSection({required this.booking, required this.isDark});

  final ServiceBookingEntity booking;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final messages = booking.feeMessages.isEmpty
        ? const <String>['Ada biaya tambahan sesuai pengaturan admin.']
        : booking.feeMessages;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: _FeeMessageList(messages: messages, isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class _FeeMessageList extends StatelessWidget {
  const _FeeMessageList({required this.messages, required this.isDark});

  final List<String> messages;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final message in messages)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _PrimaryTrackingActions extends StatelessWidget {
  const _PrimaryTrackingActions({
    required this.booking,
    required this.isOpeningPayment,
    required this.isRematchingPartner,
    required this.isLoadingBookingDetail,
    required this.onOpenDetail,
    required this.onRefreshDetail,
    required this.onPay,
    required this.onRematch,
  });

  final ServiceBookingEntity booking;
  final RxBool isOpeningPayment;
  final RxBool isRematchingPartner;
  final RxBool isLoadingBookingDetail;
  final VoidCallback onOpenDetail;
  final VoidCallback onRefreshDetail;
  final VoidCallback onPay;
  final VoidCallback onRematch;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onOpenDetail,
              icon: const Icon(Icons.receipt_long_rounded),
              label: const Text('Detail'),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: isLoadingBookingDetail.value ? null : onRefreshDetail,
            icon: isLoadingBookingDetail.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: _isPrimaryActionDisabled ? null : _onPrimaryAction,
              icon: isOpeningPayment.value || isRematchingPartner.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_primaryActionIcon),
              label: Text(_primaryActionLabel),
            ),
          ),
        ],
      ),
    );
  }

  bool get _isPrimaryActionDisabled {
    if (booking.canRequestPartnerRematch) {
      return isRematchingPartner.value;
    }
    return booking.isPaid ||
        !booking.isAcceptedByPartner ||
        isOpeningPayment.value;
  }

  VoidCallback get _onPrimaryAction {
    if (booking.canRequestPartnerRematch) {
      return onRematch;
    }
    return onPay;
  }

  IconData get _primaryActionIcon {
    if (booking.canRequestPartnerRematch) {
      return Icons.manage_search_rounded;
    }
    return Icons.payments_rounded;
  }

  String get _primaryActionLabel {
    if (booking.canRequestPartnerRematch) {
      return isRematchingPartner.value ? 'Mencari...' : 'Cari mitra lagi';
    }
    if (booking.isPaid) {
      return 'Terbayar';
    }
    if (booking.isAcceptedByPartner) {
      return 'Bayar';
    }
    return 'Menunggu Mitra';
  }
}

class _PremiumMapPreview extends StatelessWidget {
  const _PremiumMapPreview({
    required this.booking,
    required this.mapController,
    required this.routePoints,
  });

  final ServiceBookingEntity booking;
  final MapController mapController;
  final RxList<LatLng> routePoints;

  @override
  Widget build(BuildContext context) {
    if (!booking.isOnTheWay) {
      return _BookingStatusHero(booking: booking);
    }

    if (!booking.hasTrackingCoordinates) {
      return _BookingStatusHero(booking: booking);
    }

    final partnerPoint = LatLng(
      booking.partnerLatitude!,
      booking.partnerLongitude!,
    );
    final patientPoint = LatLng(
      booking.patientLatitude!,
      booking.patientLongitude!,
    );
    final center = LatLng(
      (partnerPoint.latitude + patientPoint.latitude) / 2,
      (partnerPoint.longitude + patientPoint.longitude) / 2,
    );

    return SizedBox.expand(
      child: Obx(
        () => FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags:
                  InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.medic.patient.app',
              maxZoom: 19,
            ),
            if (routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints.toList(),
                    strokeWidth: 5,
                    color: AppColors.primary,
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: partnerPoint,
                  width: 44,
                  height: 44,
                  child: const _MapPin(
                    icon: Icons.two_wheeler_rounded,
                    color: AppColors.primary,
                  ),
                ),
                Marker(
                  point: patientPoint,
                  width: 44,
                  height: 44,
                  child: const _MapPin(
                    icon: Icons.home_rounded,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingStatusHero extends StatelessWidget {
  const _BookingStatusHero({required this.booking});

  final ServiceBookingEntity booking;

  @override
  Widget build(BuildContext context) {
    final config = _StatusHeroConfig.fromBooking(booking);

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: config.backgroundColor),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _StatusPatternPainter(color: config.accentColor),
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.94, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                onEnd: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AnimatedStatusBadge(config: config),
                    const SizedBox(height: 18),
                    Text(
                      config.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Text(
                        config.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.58),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStatusBadge extends StatefulWidget {
  const _AnimatedStatusBadge({required this.config});

  final _StatusHeroConfig config;

  @override
  State<_AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<_AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant _AnimatedStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.isFinalState != widget.config.isFinalState) {
      _syncAnimationState();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    if (config.isFinalState) {
      return _StatusBadge(config: config, scale: 1);
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return _StatusBadge(config: config, scale: _scaleAnimation.value);
      },
    );
  }

  void _syncAnimationState() {
    if (widget.config.isFinalState) {
      _controller.stop();
    } else {
      _controller.repeat(reverse: true);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.config, required this.scale});

  final _StatusHeroConfig config;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.scale(
          scale: scale,
          child: Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: config.accentColor.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: config.accentColor.withValues(alpha: 0.24),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(config.icon, color: config.accentColor, size: 38),
        ),
      ],
    );
  }
}

class _StatusHeroConfig {
  const _StatusHeroConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.isFinalState,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final bool isFinalState;

  factory _StatusHeroConfig.fromBooking(ServiceBookingEntity booking) {
    final status = booking.status.toLowerCase().trim();

    if (status == 'completed') {
      return const _StatusHeroConfig(
        title: 'Layanan Selesai',
        subtitle: 'Terima kasih, layanan sudah ditandai selesai.',
        icon: Icons.check_circle_rounded,
        accentColor: AppColors.success,
        backgroundColor: Color(0xFFEFFAF5),
        isFinalState: true,
      );
    }

    if (status == 'cancelled') {
      return const _StatusHeroConfig(
        title: 'Pesanan Dibatalkan',
        subtitle: 'Pesanan ini sudah tidak aktif.',
        icon: Icons.cancel_rounded,
        accentColor: AppColors.error,
        backgroundColor: Color(0xFFFFF2F2),
        isFinalState: true,
      );
    }

    if (status == 'confirmed' || status == 'scheduled') {
      return const _StatusHeroConfig(
        title: 'Mitra Disiapkan',
        subtitle: 'Peta aktif saat mitra mulai menuju lokasi.',
        icon: Icons.medical_services_rounded,
        accentColor: AppColors.primary,
        backgroundColor: Color(0xFFEFF8F5),
        isFinalState: false,
      );
    }

    return const _StatusHeroConfig(
      title: 'Menunggu Mitra',
      subtitle: 'Kami sedang memantau status pesanan secara berkala.',
      icon: Icons.hourglass_top_rounded,
      accentColor: AppColors.warning,
      backgroundColor: Color(0xFFFFF8EA),
      isFinalState: false,
    );
  }
}

class _StatusPatternPainter extends CustomPainter {
  const _StatusPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.22), 54, paint);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.24), 74, paint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.86), 92, paint);
  }

  @override
  bool shouldRepaint(covariant _StatusPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PremiumTimeline extends StatelessWidget {
  const _PremiumTimeline({required this.booking, required this.distanceMeters});

  final ServiceBookingEntity booking;
  final RxDouble distanceMeters;

  @override
  Widget build(BuildContext context) {
    final status = booking.status.toLowerCase().trim();
    final steps = [
      _TimelineData(
        title: 'Pesanan Diterima',
        subtitle: 'Permintaan layanan sudah masuk',
        time: booking.scheduledAt,
        completed: _statusRank(status) >= 0,
      ),
      _TimelineData(
        title: 'Mitra Menerima',
        subtitle: booking.partnerName == null
            ? 'Menunggu konfirmasi mitra'
            : '${booking.partnerName} menerima pesanan',
        time: booking.acceptedAt,
        completed: _statusRank(status) >= 1,
      ),
      _TimelineData(
        title: 'Dalam Perjalanan',
        subtitle: 'Mitra menuju lokasi Anda',
        time: booking.startedAt,
        completed: _statusRank(status) >= 2,
        active: status == 'on_the_way',
      ),
      _TimelineData(
        title: 'Selesai',
        subtitle: booking.completedAt == null
            ? 'Menunggu layanan selesai'
            : 'Layanan sudah selesai',
        time: booking.completedAt,
        completed: _statusRank(status) >= 3,
        active: booking.needsPatientCompletionConfirmation,
      ),
    ];

    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          _TimelineItem(
            data: steps[index],
            isLast: index == steps.length - 1,
            distanceMeters: distanceMeters,
          ),
      ],
    );
  }

  static int _statusRank(String status) {
    switch (status) {
      case 'confirmed':
      case 'scheduled':
        return 1;
      case 'on_the_way':
        return 2;
      case 'completed':
        return 3;
      case 'cancelled':
        return -1;
      case 'pending':
      default:
        return 0;
    }
  }
}

class _TimelineData {
  const _TimelineData({
    required this.title,
    required this.subtitle,
    required this.completed,
    this.time,
    this.active = false,
  });

  final String title;
  final String subtitle;
  final String? time;
  final bool completed;
  final bool active;
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.data,
    required this.isLast,
    required this.distanceMeters,
  });

  final _TimelineData data;
  final bool isLast;
  final RxDouble distanceMeters;

  @override
  Widget build(BuildContext context) {
    final color = data.active
        ? AppColors.primary
        : data.completed
        ? const Color(0xFF69D9C4)
        : const Color(0xFFD8E2DF);
    final textColor = data.active ? AppColors.primary : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(
                data.completed ? Icons.check_rounded : Icons.circle,
                color: Colors.white,
                size: data.active ? 11 : 15,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: data.active ? 86 : 64,
                color: const Color(0xFFD8E2DF),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatTime(data.time)} - ${data.subtitle}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (data.active) ...[
                  const SizedBox(height: 10),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SoftInfoPill(
                          icon: Icons.location_on_rounded,
                          label: _formatDistance(distanceMeters.value),
                        ),
                        const _SoftInfoPill(
                          icon: Icons.traffic_rounded,
                          label: 'Lalu lintas lancar',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return '--:--';
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _formatDistance(double meters) {
    if (meters <= 0) {
      return 'Menghitung';
    }
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m lagi';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km lagi';
  }
}

class _SoftInfoPill extends StatelessWidget {
  const _SoftInfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF7EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumPartnerCard extends StatelessWidget {
  const _PremiumPartnerCard({
    required this.booking,
    required this.serviceName,
    required this.isConfirmingCompletion,
    required this.onConfirmCompletion,
  });

  final ServiceBookingEntity booking;
  final String serviceName;
  final RxBool isConfirmingCompletion;
  final VoidCallback onConfirmCompletion;

  @override
  Widget build(BuildContext context) {
    final isAccepted = booking.isAcceptedByPartner;
    final partnerName = isAccepted
        ? booking.partnerName ??
              (booking.assignedPartnerUserId == null
                  ? 'Mitra'
                  : 'Mitra #${booking.assignedPartnerUserId}')
        : booking.isSearchingReplacementPartner
        ? 'Mencari mitra pengganti'
        : 'Menunggu konfirmasi mitra';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE1F4EF),
                    child: Text(
                      _initials(partnerName),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isAccepted
                            ? AppColors.primary
                            : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isAccepted
                            ? Icons.verified_rounded
                            : Icons.hourglass_top_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isAccepted
                          ? serviceName
                          : 'Mitra belum final sebelum pesanan diterima',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () => _showPartnerProfile(context, partnerName),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
          if (booking.needsPatientCompletionConfirmation) ...[
            const SizedBox(height: 12),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isConfirmingCompletion.value
                      ? null
                      : onConfirmCompletion,
                  icon: isConfirmingCompletion.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_rounded),
                  label: const Text('Konfirmasi selesai'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'M';
    }
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  void _showPartnerProfile(BuildContext context, String partnerName) {
    final isAccepted = booking.isAcceptedByPartner;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final distance = booking.distanceKm == null
            ? '-'
            : '${booking.distanceKm!.toStringAsFixed(1)} km';
        final coordinate =
            booking.partnerLatitude == null || booking.partnerLongitude == null
            ? '-'
            : '${booking.partnerLatitude!.toStringAsFixed(6)}, '
                  '${booking.partnerLongitude!.toStringAsFixed(6)}';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8DEE7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFE1F4EF),
                      child: Text(
                        _initials(partnerName),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partnerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAccepted
                                ? 'Mitra layanan'
                                : 'Mitra belum ditetapkan',
                            style: const TextStyle(
                              color: AppColors.lightMutedText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _PartnerProfileRow(
                  icon: Icons.medical_services_rounded,
                  label: 'Layanan',
                  value: serviceName,
                ),
                _PartnerProfileRow(
                  icon: Icons.badge_rounded,
                  label: 'Nomor mitra',
                  value: booking.assignedPartnerUserId == null
                      ? '-'
                      : '#${booking.assignedPartnerUserId}',
                ),
                _PartnerProfileRow(
                  icon: Icons.verified_rounded,
                  label: 'Status',
                  value: isAccepted
                      ? 'Menerima pesanan'
                      : booking.isSearchingReplacementPartner
                      ? 'Mencari mitra pengganti'
                      : 'Menunggu konfirmasi',
                ),
                _PartnerProfileRow(
                  icon: Icons.schedule_rounded,
                  label: 'Diterima',
                  value: booking.acceptedAt ?? '-',
                ),
                _PartnerProfileRow(
                  icon: Icons.route_rounded,
                  label: 'Jarak',
                  value: distance,
                ),
                _PartnerProfileRow(
                  icon: Icons.location_on_rounded,
                  label: 'Koordinat',
                  value: coordinate,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PartnerProfileRow extends StatelessWidget {
  const _PartnerProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.lightMutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
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

class _MapPin extends StatelessWidget {
  const _MapPin({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.rows,
    required this.isDark,
  });

  final String title;
  final IconData icon;
  final List<_DetailRow> rows;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ServiceBookingDetailArguments {
  const _ServiceBookingDetailArguments({
    required this.bookingId,
    this.booking,
    this.serviceName,
    this.patientName,
  });

  final int bookingId;
  final ServiceBookingEntity? booking;
  final String? serviceName;
  final String? patientName;

  factory _ServiceBookingDetailArguments.from(dynamic value) {
    if (value is ServiceBookingEntity) {
      return _ServiceBookingDetailArguments(
        bookingId: value.id,
        booking: value,
      );
    }

    if (value is Map) {
      final booking = value['booking'] is ServiceBookingEntity
          ? value['booking'] as ServiceBookingEntity
          : null;
      return _ServiceBookingDetailArguments(
        bookingId:
            _readInt(value['bookingId'] ?? value['id']) ?? booking?.id ?? 0,
        booking: booking,
        serviceName: value['serviceName']?.toString(),
        patientName: value['patientName']?.toString(),
      );
    }

    return _ServiceBookingDetailArguments(bookingId: _readInt(value) ?? 0);
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }
}

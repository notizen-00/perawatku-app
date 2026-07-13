import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../../domain/entities/service_booking_service_entity.dart';
import '../controllers/service_booking_controller.dart';
import '../widgets/service_booking_panel.dart';

class ServiceBookingCheckoutPage extends StatefulWidget {
  const ServiceBookingCheckoutPage({super.key});

  @override
  State<ServiceBookingCheckoutPage> createState() =>
      _ServiceBookingCheckoutPageState();
}

class _ServiceBookingCheckoutPageState
    extends State<ServiceBookingCheckoutPage> {
  late final ServiceBookingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ServiceBookingController>();
    final argument = Get.arguments;
    if (argument is ServiceBookingServiceEntity) {
      controller.primeSelectedService(argument);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFF8FBFA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        title: Obx(
          () => Text(
            controller.selectedService.value?.name ?? 'Checkout Layanan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        children: const [
          ServiceBookingPanel(
            showHeader: false,
            showServicePicker: false,
            showSubmitButton: false,
            showLatestStatus: false,
          ),
          SizedBox(height: 14),
          _TransportInfoCard(),
        ],
      ),
      bottomNavigationBar: _CheckoutBottomBar(controller: controller),
    );
  }
}

class _TransportInfoCard extends StatelessWidget {
  const _TransportInfoCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1B19) : const Color(0xFFEFFAF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Info transportasi',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  'Biaya transport mengikuti backend-service-fee. Untuk jadwal recurring visit, biaya dapat muncul jika jarak mitra melebihi ambang admin. Ringkasan final tampil setelah checkout.',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.lightMutedText,
                    fontSize: 12.5,
                    height: 1.45,
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

class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({required this.controller});

  final ServiceBookingController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Obx(() {
          final service = controller.selectedService.value;
          final estimate = _estimateLabel(service);

          return Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimasi harga',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightMutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      estimate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: controller.isCreatingBooking.value
                      ? null
                      : () => _checkout(context),
                  child: controller.isCreatingBooking.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Proses Checkout',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _checkout(BuildContext context) async {
    final loadingFuture = Get.dialog<void>(
      const _CheckoutLoadingDialog(),
      barrierDismissible: false,
    );
    final createFuture = controller.createBooking();

    final results = await Future.wait<Object?>([
      createFuture,
      Future<void>.delayed(const Duration(seconds: 4)).then((_) => null),
    ]);
    final booking = results.first as ServiceBookingEntity?;
    final serviceName = controller.selectedService.value?.name;
    final patientName = controller.selectedPatientMember.value?.name;

    if (Get.isDialogOpen == true) {
      Get.back<void>();
    }
    await loadingFuture;

    if (booking == null) {
      return;
    }

    await Get.offNamed(
      AppRoutes.serviceBookingDetail,
      arguments: {
        'bookingId': booking.id,
        'booking': booking,
        'serviceName': serviceName,
        'patientName': patientName,
      },
    );
    await controller.resetMatchmakingForm(reloadCatalog: false);
  }

  String _estimateLabel(ServiceBookingServiceEntity? service) {
    if (service == null) {
      return '-';
    }

    return CurrencyFormatter.formatRupiahFromString(
      service.price,
      emptyValue: 'Menyesuaikan',
    );
  }
}

class _CheckoutLoadingDialog extends StatelessWidget {
  const _CheckoutLoadingDialog();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 44),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 132,
                height: 132,
                child: Lottie.asset(
                  'assets/medic-loading.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Memproses checkout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Backend menghitung ringkasan biaya dan mencarikan mitra.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkMutedText
                      : AppColors.lightMutedText,
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

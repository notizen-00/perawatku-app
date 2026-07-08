import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/services/midtrans_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../nurse/domain/usecases/get_nurses_use_case.dart';
import '../../../patient_member/domain/usecases/get_patient_members_use_case.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../../domain/usecases/check_promo_code_use_case.dart';
import '../../domain/usecases/create_service_booking_use_case.dart';
import '../../domain/usecases/get_service_booking_services_use_case.dart';
import '../../domain/usecases/get_service_booking_use_case.dart';
import '../../domain/usecases/pay_service_booking_use_case.dart';
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

  @override
  void initState() {
    super.initState();
    controller = _ensureController();
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
      appBar: AppBar(
        title: const Text('Detail Booking'),
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
                onRetry: () => controller.loadBookingDetail(arguments.bookingId),
              ),
            ),
          );
        }

        if (booking == null) {
          return const Center(child: Text('Detail booking belum tersedia.'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadBookingDetail(arguments.bookingId),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _SummaryCard(
                booking: booking,
                serviceName:
                    booking.serviceName ?? arguments.serviceName ?? '-',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _DetailSection(
                title: 'Layanan',
                icon: Icons.medical_services_rounded,
                rows: [
                  _DetailRow(
                    label: 'Nama layanan',
                    value: booking.serviceName ?? arguments.serviceName ?? '-',
                  ),
                  _DetailRow(
                    label: 'ID layanan',
                    value: booking.serviceId?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Jadwal',
                    value: _formatDateTime(booking.scheduledAt),
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
                    value: booking.patientMemberName ??
                        arguments.patientName ??
                        '-',
                  ),
                  _DetailRow(
                    label: 'ID pasien member',
                    value: booking.patientMemberId?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Mitra',
                    value: booking.partnerName ??
                        (booking.assignedPartnerUserId == null
                            ? '-'
                            : '#${booking.assignedPartnerUserId}'),
                  ),
                  _DetailRow(
                    label: 'Alamat pasien',
                    value: booking.patientAddressId == null
                        ? '-'
                        : '#${booking.patientAddressId}',
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
                    label: 'Total',
                    value: CurrencyFormatter.formatRupiahFromString(
                      booking.totalAmount,
                      emptyValue: '-',
                    ),
                  ),
                  _DetailRow(
                    label: 'Status bayar',
                    value: booking.paymentStatus ?? 'pending',
                  ),
                  _DetailRow(
                    label: 'Referensi',
                    value: booking.paymentReference ?? '-',
                  ),
                  _DetailRow(
                    label: 'Snap token',
                    value: booking.snapToken == null ? '-' : 'Tersedia',
                  ),
                ],
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _MatchmakingSection(booking: booking, isDark: isDark),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isLoadingBookingDetail.value
                          ? null
                          : () =>
                              controller.loadBookingDetail(arguments.bookingId),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          booking.isPaid || controller.isOpeningPayment.value
                              ? null
                              : () async {
                                  controller.latestBooking.value = booking;
                                  await controller.openLatestBookingPayment();
                                  await controller.loadBookingDetail(
                                    arguments.bookingId,
                                  );
                                },
                      icon: controller.isOpeningPayment.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.payments_rounded),
                      label: Text(booking.isPaid ? 'Terbayar' : 'Bayar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.booking,
    required this.serviceName,
    required this.isDark,
  });

  final ServiceBookingEntity booking;
  final String serviceName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final statusColor = booking.isPaid ? AppColors.success : AppColors.warning;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.home_repair_service_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.bookingCode,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceName,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightMutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(label: booking.status, color: AppColors.info),
              _StatusPill(
                label: booking.paymentStatus ?? 'pending',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.formatRupiahFromString(
              booking.totalAmount,
              emptyValue: '-',
            ),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchmakingSection extends StatelessWidget {
  const _MatchmakingSection({required this.booking, required this.isDark});

  final ServiceBookingEntity booking;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final matchmaking = booking.matchmaking;

    return _DetailSection(
      title: 'Matchmaking',
      icon: Icons.route_rounded,
      rows: [
        _DetailRow(
          label: 'Mitra matched',
          value: matchmaking?.partnerUserId == null
              ? '-'
              : '#${matchmaking!.partnerUserId}',
        ),
        _DetailRow(
          label: 'Partner service',
          value: matchmaking?.partnerServiceId == null
              ? '-'
              : '#${matchmaking!.partnerServiceId}',
        ),
        _DetailRow(
          label: 'Jarak',
          value: matchmaking?.distanceKm == null
              ? '-'
              : '${matchmaking!.distanceKm!.toStringAsFixed(1)} km',
        ),
        _DetailRow(
          label: 'Skor match',
          value: matchmaking?.matchScore == null
              ? '-'
              : matchmaking!.matchScore!.toStringAsFixed(1),
        ),
        _DetailRow(
          label: 'Skor kualitas',
          value: matchmaking?.qualityScore == null
              ? '-'
              : matchmaking!.qualityScore!.toStringAsFixed(1),
        ),
      ],
      isDark: isDark,
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
        bookingId: _readInt(value['bookingId'] ?? value['id']) ??
            booking?.id ??
            0,
        booking: booking,
        serviceName: value['serviceName']?.toString(),
        patientName: value['patientName']?.toString(),
      );
    }

    return _ServiceBookingDetailArguments(
      bookingId: _readInt(value) ?? 0,
    );
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

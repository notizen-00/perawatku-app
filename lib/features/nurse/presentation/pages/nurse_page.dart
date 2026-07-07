import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/nurse_entity.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../../domain/entities/service_booking_service_entity.dart';
import '../controllers/nurse_controller.dart';

class NursePage extends GetView<NurseController> {
  const NursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perawat')),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.loadNurses(),
              controller.loadServices(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _ServiceBookingPanel(),
              const SizedBox(height: 18),
              Text(
                'Perawat terdekat',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (controller.isLoading.value && controller.nurses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.errorMessage.value != null &&
                  controller.nurses.isEmpty)
                _StateMessage(
                  title: 'Perawat belum bisa dimuat',
                  description: controller.errorMessage.value!,
                  actionLabel: 'Coba lagi',
                  onTap: controller.loadNurses,
                )
              else if (controller.nurses.isEmpty)
                const _StateMessage(
                  title: 'Belum ada perawat',
                  description:
                      'Data perawat yang tersedia akan tampil di halaman ini.',
                )
              else
                ...controller.nurses.map(
                  (nurse) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NurseListCard(nurse: nurse),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _ServiceBookingPanel extends GetView<NurseController> {
  const _ServiceBookingPanel();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8),
        ),
      ),
      child: Obx(() {
        final booking = controller.latestBooking.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking homecare',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Matchmaking berjalan setelah booking dibuat.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (controller.isLoadingServices.value)
              const LinearProgressIndicator(minHeight: 3)
            else if (controller.serviceErrorMessage.value != null)
              _InlineError(
                message: controller.serviceErrorMessage.value!,
                onRetry: () => controller.loadServices(),
              )
            else if (controller.services.isEmpty)
              _InlineError(
                message: 'Katalog layanan belum tersedia dari backend.',
                onRetry: () => controller.loadServices(),
              )
            else
              _ServicePicker(
                services: controller.services,
                selectedService: controller.selectedService.value,
                onChanged: (service) {
                  if (service != null) {
                    controller.selectService(service);
                  }
                },
              ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.patientAddressIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID alamat pasien',
                prefixIcon: Icon(Icons.location_on_rounded),
                hintText: 'Contoh: 10',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.scheduledAtController,
              decoration: const InputDecoration(
                labelText: 'Jadwal opsional',
                prefixIcon: Icon(Icons.event_rounded),
                hintText: 'YYYY-MM-DD HH:mm:ss',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan pasien',
                prefixIcon: Icon(Icons.notes_rounded),
                hintText: 'Keluhan, kondisi pasien, atau instruksi kunjungan',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.promoCodeController,
              decoration: const InputDecoration(
                labelText: 'Kode promo opsional',
                prefixIcon: Icon(Icons.local_offer_rounded),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.isCreatingBooking.value
                    ? null
                    : controller.createBooking,
                icon: controller.isCreatingBooking.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.route_rounded),
                label: Text(
                  controller.isCreatingBooking.value
                      ? 'Membuat booking...'
                      : 'Buat booking & matchmaking',
                ),
              ),
            ),
            if (!controller.isMidtransReady) ...[
              const SizedBox(height: 10),
              Text(
                'Pembayaran Midtrans aktif di Android/iOS jika client key dan merchant base URL sudah diisi.',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkMutedText
                      : AppColors.lightMutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (booking != null) ...[
              const SizedBox(height: 14),
              _BookingStatusCard(booking: booking),
            ],
          ],
        );
      }),
    );
  }
}

class _ServicePicker extends StatelessWidget {
  const _ServicePicker({
    required this.services,
    required this.selectedService,
    required this.onChanged,
  });

  final List<ServiceBookingServiceEntity> services;
  final ServiceBookingServiceEntity? selectedService;
  final ValueChanged<ServiceBookingServiceEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ServiceBookingServiceEntity>(
      value: selectedService,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Layanan',
        prefixIcon: Icon(Icons.medical_services_rounded),
      ),
      items: services
          .map(
            (service) => DropdownMenuItem(
              value: service,
              child: Text(
                _serviceLabel(service),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  static String _serviceLabel(ServiceBookingServiceEntity service) {
    final price = CurrencyFormatter.formatRupiahFromString(
      service.price,
      emptyValue: '',
    );
    return price.isEmpty ? service.name : '${service.name} - $price';
  }
}

class _BookingStatusCard extends GetView<NurseController> {
  const _BookingStatusCard({required this.booking});

  final ServiceBookingEntity booking;

  @override
  Widget build(BuildContext context) {
    final isPaid = booking.isPaid;
    final matchmaking = booking.matchmaking;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isPaid ? AppColors.success : const Color(0xFFF59E0B))
            .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (isPaid ? AppColors.success : const Color(0xFFF59E0B))
              .withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPaid ? Icons.verified_rounded : Icons.lock_clock_rounded,
                color: isPaid ? AppColors.success : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isPaid ? 'Pembayaran selesai' : 'Selesaikan pembayaran dulu',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoLine(label: 'Kode', value: booking.bookingCode),
          _InfoLine(label: 'Status booking', value: booking.status),
          _InfoLine(
            label: 'Status bayar',
            value: booking.paymentStatus ?? 'pending',
          ),
          _InfoLine(
            label: 'Total',
            value: CurrencyFormatter.formatRupiahFromString(
              booking.totalAmount,
              emptyValue: '-',
            ),
          ),
          if (matchmaking != null) ...[
            const Divider(height: 18),
            _InfoLine(
              label: 'Mitra matched',
              value: '#${matchmaking.partnerUserId ?? '-'}',
            ),
            _InfoLine(
              label: 'Jarak',
              value: matchmaking.distanceKm == null
                  ? '-'
                  : '${matchmaking.distanceKm!.toStringAsFixed(1)} km',
            ),
            _InfoLine(
              label: 'Skor match',
              value: matchmaking.matchScore == null
                  ? '-'
                  : matchmaking.matchScore!.toStringAsFixed(1),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isRefreshingBooking.value
                      ? null
                      : () => controller.refreshLatestBooking(),
                  icon: controller.isRefreshingBooking.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: (isPaid || controller.isOpeningPayment.value)
                      ? null
                      : controller.openLatestBookingPayment,
                  icon: controller.isOpeningPayment.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payments_rounded),
                  label: Text(isPaid ? 'Siap' : 'Bayar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
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

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    );
  }
}

class _NurseListCard extends StatelessWidget {
  const _NurseListCard({required this.nurse});

  final NurseEntity nurse;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final partner = nurse.partnerProfile;
    final photoUrl = _resolvePhotoUrl(partner?.photoUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 72,
              height: 72,
              child: photoUrl == null
                  ? Container(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      alignment: Alignment.center,
                      child: const Icon(Icons.person_rounded, size: 34),
                    )
                  : Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person_rounded, size: 34),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nurse.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (partner?.specialization ?? '').trim().isEmpty
                      ? 'Perawat'
                      : partner!.specialization,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.lightMutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.formatRupiahFromString(
                    partner?.consultationFee,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChipLabel(
                      icon: Icons.place_rounded,
                      label: nurse.distanceKm == null
                          ? 'Jarak belum tersedia'
                          : '${nurse.distanceKm!.toStringAsFixed(1)} km',
                    ),
                    _ChipLabel(
                      icon: partner?.isAvailable == true
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      label: partner?.isAvailable == true
                          ? 'Tersedia'
                          : 'Belum tersedia',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _resolvePhotoUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      return null;
    }

    if (uri.hasScheme) {
      return uri.toString();
    }

    final normalizedPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
    return '${AppConfig.baseUrl}$normalizedPath';
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            if (actionLabel != null && onTap != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onTap, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

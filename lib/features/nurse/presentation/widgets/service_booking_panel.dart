import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../patient_member/domain/entities/patient_member_entity.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../../domain/entities/service_booking_service_entity.dart';
import '../controllers/nurse_controller.dart';
import 'inline_error.dart';

class ServiceBookingPanel extends GetView<NurseController> {
  const ServiceBookingPanel({super.key});

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
            const _BookingPanelHeader(),
            const SizedBox(height: 14),
            _ServicePickerSection(controller: controller),
            const SizedBox(height: 12),
            _PatientMemberPicker(
              members: controller.patientMembers,
              selectedMember: controller.selectedPatientMember.value,
              isLoading: controller.isLoadingMembers.value,
              errorMessage: controller.memberErrorMessage.value,
              onReload: controller.loadPatientMembers,
              onChanged: controller.selectPatientMember,
            ),
            const SizedBox(height: 10),
            _ScheduledAtField(controller: controller),
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
            _PromoCodeField(controller: controller),
            const SizedBox(height: 12),
            _PriceRangeCard(controller: controller),
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

class _BookingPanelHeader extends StatelessWidget {
  const _BookingPanelHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
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
    );
  }
}

class _ServicePickerSection extends StatelessWidget {
  const _ServicePickerSection({required this.controller});

  final NurseController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingServices.value) {
      return const LinearProgressIndicator(minHeight: 3);
    }

    final error = controller.serviceErrorMessage.value;
    if (error != null) {
      return InlineError(
        message: error,
        onRetry: () => controller.loadServices(),
      );
    }

    if (controller.services.isEmpty) {
      return InlineError(
        message: 'Katalog layanan belum tersedia dari backend.',
        onRetry: () => controller.loadServices(),
      );
    }

    final categories = controller.serviceCategories;
    final selectedCategory = controller.selectedServiceCategory;
    final filteredServices = controller.filteredServices;

    return Column(
      children: [
        _ServiceCategoryPicker(
          categories: categories,
          selectedCategory: selectedCategory,
          onChanged: controller.selectServiceCategory,
        ),
        const SizedBox(height: 10),
        if (filteredServices.isEmpty)
          InlineError(
            message: 'Belum ada layanan pada kategori ini.',
            onRetry: () => controller.loadServices(),
          )
        else
          _ServicePicker(
            services: filteredServices,
            selectedService: controller.selectedService.value,
            onChanged: (service) {
              if (service != null) {
                controller.selectService(service);
              }
            },
          ),
      ],
    );
  }
}

class _ServiceCategoryPicker extends StatelessWidget {
  const _ServiceCategoryPicker({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<ServiceCategoryOption> categories;
  final ServiceCategoryOption? selectedCategory;
  final ValueChanged<ServiceCategoryOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = categories.any(
      (category) => category.key == selectedCategory?.key,
    )
        ? selectedCategory
        : null;

    return DropdownButtonFormField<ServiceCategoryOption>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Kategori layanan',
        prefixIcon: Icon(Icons.category_rounded),
      ),
      items: categories
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Text(category.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
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
    final value = services.any(
      (service) =>
          service.bookingServiceId == selectedService?.bookingServiceId,
    )
        ? selectedService
        : null;

    return DropdownButtonFormField<ServiceBookingServiceEntity>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Nama layanan',
        prefixIcon: Icon(Icons.medical_services_rounded),
      ),
      items: services
          .map(
            (service) => DropdownMenuItem(
              value: service,
              child: Text(service.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _PatientMemberPicker extends StatelessWidget {
  const _PatientMemberPicker({
    required this.members,
    required this.selectedMember,
    required this.isLoading,
    required this.errorMessage,
    required this.onReload,
    required this.onChanged,
  });

  final List<PatientMemberEntity> members;
  final PatientMemberEntity? selectedMember;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onReload;
  final ValueChanged<PatientMemberEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LinearProgressIndicator(minHeight: 3);
    }

    if (errorMessage != null && members.isEmpty) {
      return InlineError(message: errorMessage!, onRetry: onReload);
    }

    if (members.isEmpty) {
      return InlineError(
        message: 'Belum ada profil pasien keluarga. Tambahkan dulu di menu Akun.',
        onRetry: onReload,
      );
    }

    final value = members.any((member) => member.id == selectedMember?.id)
        ? selectedMember
        : null;

    return DropdownButtonFormField<PatientMemberEntity>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Profil pasien',
        prefixIcon: Icon(Icons.group_rounded),
      ),
      items: members
          .map(
            (member) => DropdownMenuItem(
              value: member,
              child: Text(
                _memberLabel(member),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  String _memberLabel(PatientMemberEntity member) {
    final relationship = member.relationship.trim();
    return relationship.isEmpty ? member.name : '${member.name} - $relationship';
  }
}

class _ScheduledAtField extends StatelessWidget {
  const _ScheduledAtField({required this.controller});

  final NurseController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.scheduledAtController,
      readOnly: true,
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: now.add(const Duration(days: 1)),
          firstDate: now,
          lastDate: now.add(const Duration(days: 90)),
        );
        if (date == null || !context.mounted) {
          return;
        }

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
            now.add(const Duration(hours: 1)),
          ),
        );
        if (time == null) {
          return;
        }

        await controller.pickScheduledAt(date, time);
      },
      decoration: InputDecoration(
        labelText: 'Jadwal kunjungan opsional',
        prefixIcon: const Icon(Icons.event_rounded),
        hintText: 'Pilih tanggal dan jam',
        suffixIcon: controller.scheduledAtController.text.trim().isEmpty
            ? null
            : IconButton(
                onPressed: controller.scheduledAtController.clear,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

class _PromoCodeField extends StatelessWidget {
  const _PromoCodeField({required this.controller});

  final NurseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.promoCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Kode promo opsional',
              prefixIcon: const Icon(Icons.local_offer_rounded),
              suffixIcon: TextButton(
                onPressed: controller.isCheckingPromo.value
                    ? null
                    : controller.checkPromoCode,
                child: controller.isCheckingPromo.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cek'),
              ),
            ),
          ),
          if (controller.promoStatusMessage.value != null) ...[
            const SizedBox(height: 6),
            Text(
              controller.promoStatusMessage.value!,
              style: TextStyle(
                color: controller.isPromoValid.value
                    ? AppColors.success
                    : AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceRangeCard extends StatelessWidget {
  const _PriceRangeCard({required this.controller});

  final NurseController controller;

  @override
  Widget build(BuildContext context) {
    final service = controller.selectedService.value;
    final member = controller.selectedPatientMember.value;
    final nearest = controller.nearestNurse;
    final servicePrice = CurrencyFormatter.formatRupiahFromString(
      service?.price,
      emptyValue: '-',
    );
    final distance = nearest?.distanceKm;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.request_quote_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Estimasi harga & jarak',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoLine(label: 'Harga layanan', value: servicePrice),
          _InfoLine(
            label: 'Profil pasien',
            value: member == null ? '-' : member.name,
          ),
          _InfoLine(
            label: 'Mitra terdekat',
            value: nearest == null ? '-' : nearest.name,
          ),
          _InfoLine(
            label: 'Jarak',
            value: distance == null ? '-' : '${distance.toStringAsFixed(1)} km',
          ),
          const SizedBox(height: 6),
          const Text(
            'Total final, diskon promo, markup, dan match distance resmi mengikuti response backend setelah booking dibuat.',
            style: TextStyle(
              color: AppColors.lightMutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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

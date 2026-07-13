import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../patient_member/domain/entities/patient_member_entity.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../../domain/entities/service_booking_service_entity.dart';
import '../controllers/service_booking_controller.dart';
import 'inline_error.dart';

class ServiceBookingPanel extends GetView<ServiceBookingController> {
  const ServiceBookingPanel({
    super.key,
    this.showHeader = true,
    this.showServicePicker = true,
    this.showSubmitButton = true,
    this.showLatestStatus = true,
  });

  final bool showHeader;
  final bool showServicePicker;
  final bool showSubmitButton;
  final bool showLatestStatus;

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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              const _BookingPanelHeader(),
              const SizedBox(height: 14),
            ],
            if (showServicePicker) ...[
              _ServicePickerSection(controller: controller),
              const SizedBox(height: 12),
            ],
            _PatientMemberPicker(
              members: controller.patientMembers,
              selectedMember: controller.selectedPatientMember.value,
              isLoading: controller.isLoadingMembers.value,
              errorMessage: controller.memberErrorMessage.value,
              onReload: controller.loadPatientMembers,
              onOpenPicker: () async {
                await Get.toNamed(AppRoutes.serviceBookingPatientPicker);
              },
            ),
            const SizedBox(height: 10),
            _ScheduleForm(controller: controller),
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
            if (showSubmitButton) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.isCreatingBooking.value
                      ? null
                      : () => _createBookingWithLoading(context),
                  icon: controller.isCreatingBooking.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payments_rounded),
                  label: Text(
                    controller.isCreatingBooking.value
                        ? 'Membuat booking...'
                        : 'Buat booking & lanjut bayar',
                  ),
                ),
              ),
            ],
            if (showLatestStatus && controller.latestBooking.value != null) ...[
              const SizedBox(height: 12),
              _MatchmakingStatusCard(
                isPaid: controller.latestBooking.value?.isPaid == true,
                hasPartner:
                    controller.latestBooking.value?.matchmaking != null,
                onOpenDetail: controller.openLatestBookingDetail,
              ),
            ],
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
          ],
        );
      }),
    );
  }

  Future<void> _createBookingWithLoading(BuildContext context) async {
    final loadingFuture = _showBookingLoadingDialog(context);
    final createFuture = controller.createBooking();

    final results = await Future.wait<Object?>([
      createFuture,
      Future<void>.delayed(const Duration(seconds: 4)).then(
        (_) => null,
      ),
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

    await Get.toNamed(
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

  Future<void> _showBookingLoadingDialog(BuildContext context) {
    return Get.dialog<void>(
      const _BookingLoadingDialog(),
      barrierDismissible: false,
    );
  }
}

class _BookingLoadingDialog extends StatelessWidget {
  const _BookingLoadingDialog();

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.12),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
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
                'Menyiapkan booking',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kami sedang memproses layanan dan estimasi pembayaran.',
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

class _MatchmakingStatusCard extends StatelessWidget {
  const _MatchmakingStatusCard({
    required this.isPaid,
    required this.hasPartner,
    required this.onOpenDetail,
  });

  final bool isPaid;
  final bool hasPartner;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0D1B19) : const Color(0xFFF2FBF8);
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasPartner
                  ? Icons.verified_rounded
                  : isPaid
                  ? Icons.manage_search_rounded
                  : Icons.payments_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPartner
                      ? 'Mitra layanan ditemukan'
                      : isPaid
                      ? 'Pembayaran diterima'
                      : 'Selesaikan pembayaran dulu',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPartner
                      ? 'Mitra sudah ditetapkan untuk booking ini.'
                      : isPaid
                      ? 'Backend sedang mencari mitra yang sesuai untuk layanan ini.'
                      : 'Matchmaking akan berjalan setelah pembayaran berhasil.',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.lightMutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: onOpenDetail,
                    icon: Icon(
                      isPaid
                          ? Icons.receipt_long_rounded
                          : Icons.payments_rounded,
                      size: 18,
                    ),
                    label: Text(
                      hasPartner
                          ? 'Lihat detail'
                          : isPaid
                          ? 'Cek status mitra'
                          : 'Lanjut bayar',
                    ),
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

  final ServiceBookingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.isLoadingServices.value &&
            controller.serviceCategories.isEmpty) {
          return const LinearProgressIndicator(minHeight: 3);
        }

        final categories = controller.serviceCategories;
        final error = controller.serviceErrorMessage.value;
        if (categories.isEmpty) {
          if (error != null) {
            return InlineError(
              message: error,
              onRetry: () {
                controller.loadServiceCategories();
              },
            );
          }

          return InlineError(
            message: 'Katalog layanan belum tersedia dari backend.',
            onRetry: () {
              controller.loadServiceCategories();
            },
          );
        }

        final selectedCategory = controller.selectedServiceCategory;
        final categoryServices = selectedCategory == null
            ? const <ServiceBookingServiceEntity>[]
            : controller.services.toList();
        final selectedService = controller.selectedService.value;
        final isLoadingCategoryServices =
            controller.isLoadingCategoryServices.value;

        return Column(
          children: [
            _ServiceCategoryPicker(
              key: ValueKey('category-${selectedCategory?.key ?? 'empty'}'),
              categories: categories,
              selectedCategory: selectedCategory,
              onChanged: (category) {
                controller.selectServiceCategory(category);
              },
            ),
            const SizedBox(height: 10),
            if (error != null)
              InlineError(
                message: error,
                onRetry: () {
                  controller.reloadSelectedCategoryServices();
                },
              )
            else if (selectedCategory == null)
              _ServicePicker(
                services: const <ServiceBookingServiceEntity>[],
                selectedService: null,
                hasSelectedCategory: false,
                isLoading: false,
                onChanged: (_) {},
              )
            else if (categoryServices.isEmpty && !isLoadingCategoryServices)
              _ServicePicker(
                key: ValueKey('service-empty-${selectedCategory.key}'),
                services: const <ServiceBookingServiceEntity>[],
                selectedService: null,
                hasSelectedCategory: true,
                isLoading: false,
                emptyText: 'Belum ada layanan pada kategori ini.',
                onChanged: (_) {},
              )
            else
              _ServicePicker(
                key: ValueKey(
                  'service-${selectedCategory.key}-${selectedService?.bookingServiceId}-${categoryServices.length}-$isLoadingCategoryServices',
                ),
                services: categoryServices,
                selectedService: selectedService,
                hasSelectedCategory: true,
                isLoading: isLoadingCategoryServices,
                onChanged: (service) {
                  if (service != null) {
                    controller.selectService(service);
                  }
                },
              ),
          ],
        );
      },
    );
  }
}

class _ServiceCategoryPicker extends StatelessWidget {
  const _ServiceCategoryPicker({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<ServiceCategoryOption> categories;
  final ServiceCategoryOption? selectedCategory;
  final ValueChanged<ServiceCategoryOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = _matchingCategory;

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

  ServiceCategoryOption? get _matchingCategory {
    final selectedKey = selectedCategory?.key;
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
}

class _ServicePicker extends StatelessWidget {
  const _ServicePicker({
    super.key,
    required this.services,
    required this.selectedService,
    required this.hasSelectedCategory,
    required this.isLoading,
    required this.onChanged,
    this.emptyText,
  });

  final List<ServiceBookingServiceEntity> services;
  final ServiceBookingServiceEntity? selectedService;
  final bool hasSelectedCategory;
  final bool isLoading;
  final ValueChanged<ServiceBookingServiceEntity?> onChanged;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final value = _selectedServiceId;

    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Nama layanan',
        prefixIcon: const Icon(Icons.medical_services_rounded),
        hintText: isLoading
            ? 'Memuat layanan...'
            : emptyText != null
                ? emptyText
            : hasSelectedCategory
                ? 'Pilih layanan'
                : 'Pilih kategori dulu',
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      items: services
          .map(
            (service) => DropdownMenuItem(
              value: service.bookingServiceId,
              child: Text(service.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: !hasSelectedCategory
          ? null
          : (serviceId) {
              if (serviceId == null) {
                return;
              }

              for (final service in services) {
                if (service.bookingServiceId == serviceId) {
                  onChanged(service);
                  return;
                }
              }
            },
    );
  }

  int? get _selectedServiceId {
    if (services.isEmpty) {
      return null;
    }

    final selectedId = selectedService?.bookingServiceId;
    if (selectedId == null) {
      return services.first.bookingServiceId;
    }

    for (final service in services) {
      if (service.bookingServiceId == selectedId) {
        return selectedId;
      }
    }

    return services.first.bookingServiceId;
  }
}

class _PatientMemberPicker extends StatelessWidget {
  const _PatientMemberPicker({
    required this.members,
    required this.selectedMember,
    required this.isLoading,
    required this.errorMessage,
    required this.onReload,
    required this.onOpenPicker,
  });

  final List<PatientMemberEntity> members;
  final PatientMemberEntity? selectedMember;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onReload;
  final VoidCallback onOpenPicker;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LinearProgressIndicator(minHeight: 3);
    }

    if (errorMessage != null && members.isEmpty) {
      return InlineError(message: errorMessage!, onRetry: onReload);
    }

    if (members.isEmpty) {
      return _PatientPickerCard(
        selectedMember: null,
        label: 'Belum ada profil pasien',
        description: 'Tambah atau pilih pasien penerima layanan',
        onOpenPicker: onOpenPicker,
      );
    }

    final selected = _matchingMember;

    return _PatientPickerCard(
      selectedMember: selected,
      label: selected?.name ?? 'Profil pasien',
      description: selected == null
          ? 'Pilih pasien penerima layanan'
          : _memberLabel(selected),
      onOpenPicker: onOpenPicker,
    );
  }

  PatientMemberEntity? get _matchingMember {
    final selectedId = selectedMember?.id;
    if (selectedId == null) {
      return null;
    }

    for (final member in members) {
      if (member.id == selectedId) {
        return member;
      }
    }

    return null;
  }

  String _memberLabel(PatientMemberEntity member) {
    final relationship = member.relationship.trim();
    return relationship.isEmpty ? 'Keluarga' : relationship;
  }
}

class _PatientPickerCard extends StatelessWidget {
  const _PatientPickerCard({
    required this.selectedMember,
    required this.label,
    required this.description,
    required this.onOpenPicker,
  });

  final PatientMemberEntity? selectedMember;
  final String label;
  final String description;
  final VoidCallback onOpenPicker;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0D1B19)
            : const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedMember == null
              ? const Color(0xFFE7E1D8)
              : AppColors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: selectedMember == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.lightMutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.lightMutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: onOpenPicker,
            icon: const Icon(Icons.group_rounded, size: 18),
            label: Text(selectedMember == null ? 'Pilih' : 'Ganti'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleForm extends StatelessWidget {
  const _ScheduleForm({required this.controller});

  final ServiceBookingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRecurring = controller.isRecurringSchedule;
      final selectedSchedule = controller.selectedScheduleOption.value;
      final supportsRecurring =
          controller.selectedServiceSupportsRecurringSchedule;

      return Column(
        children: [
          if (supportsRecurring) ...[
            DropdownButtonFormField<String>(
              value: selectedSchedule,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Pola jadwal',
                prefixIcon: Icon(Icons.event_repeat_rounded),
              ),
              items: const [
                DropdownMenuItem(
                  value: ServiceScheduleOption.once,
                  child: Text('Sekali visit'),
                ),
                DropdownMenuItem(
                  value: ServiceScheduleOption.weekly,
                  child: Text('Mingguan'),
                ),
                DropdownMenuItem(
                  value: ServiceScheduleOption.monthly,
                  child: Text('Bulanan'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.selectScheduleOption(value);
                }
              },
            ),
            const SizedBox(height: 10),
          ],
          _ScheduledAtField(
            controller: controller,
            labelText: isRecurring
                ? 'Tanggal mulai kunjungan'
                : 'Tanggal kunjungan',
          ),
          if (isRecurring) ...[
            const SizedBox(height: 10),
            TextField(
              controller: controller.visitCountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Jumlah kunjungan',
                prefixIcon: Icon(Icons.format_list_numbered_rounded),
                hintText: 'Minimal 2, maksimal 52',
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: controller.selectedCareMode.value,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Mode rawat',
                    prefixIcon: Icon(Icons.medical_information_rounded),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: ServiceCareMode.visit,
                      child: Text('Visit'),
                    ),
                    if (supportsRecurring)
                      DropdownMenuItem(
                        value: ServiceCareMode.liveIn,
                        enabled: isRecurring,
                        child: const Text('Live-in'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedCareMode.value = value;
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: controller.selectedLocationType.value,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ServiceBookingLocationType.home,
                      child: Text('Rumah'),
                    ),
                    DropdownMenuItem(
                      value: ServiceBookingLocationType.hospital,
                      child: Text('RS'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedLocationType.value = value;
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _ScheduledAtField extends StatelessWidget {
  const _ScheduledAtField({
    required this.controller,
    required this.labelText,
  });

  final ServiceBookingController controller;
  final String labelText;

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
        labelText: labelText,
        prefixIcon: const Icon(Icons.event_rounded),
        hintText: 'Pilih tanggal dan jam mulai',
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

  final ServiceBookingController controller;

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


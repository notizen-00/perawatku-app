import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../patient_member/domain/entities/patient_member_entity.dart';
import '../../domain/entities/service_booking_service_entity.dart';
import '../controllers/service_booking_controller.dart';
import 'inline_error.dart';

class ServiceBookingPanel extends GetView<ServiceBookingController> {
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

  final ServiceBookingController controller;

  @override
  Widget build(BuildContext context) {
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
    final isLoadingCategoryServices =
        controller.isLoadingCategoryServices.value;

    return Column(
      children: [
        _ServiceCategoryPicker(
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
          InlineError(
            message: 'Belum ada layanan pada kategori ini.',
            onRetry: () {
              controller.reloadSelectedCategoryServices();
            },
          )
        else
          _ServicePicker(
            key: ValueKey(
              '${selectedCategory.key}-${controller.selectedService.value?.bookingServiceId}-${categoryServices.length}-$isLoadingCategoryServices',
            ),
            services: categoryServices,
            selectedService: controller.selectedService.value,
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
  });

  final List<ServiceBookingServiceEntity> services;
  final ServiceBookingServiceEntity? selectedService;
  final bool hasSelectedCategory;
  final bool isLoading;
  final ValueChanged<ServiceBookingServiceEntity?> onChanged;

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

    final value = _matchingMember;

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
    return relationship.isEmpty ? member.name : '${member.name} - $relationship';
  }
}

class _ScheduledAtField extends StatelessWidget {
  const _ScheduledAtField({required this.controller});

  final ServiceBookingController controller;

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


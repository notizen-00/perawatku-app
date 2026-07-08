import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../nurse/domain/entities/service_booking_service_entity.dart';
import '../controller/home_controller.dart';

class HomeServiceGrid extends StatelessWidget {
  HomeServiceGrid({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingServices.value &&
          controller.serviceCatalog.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final error = controller.serviceErrorMessage.value;
      if (error != null && controller.serviceCatalog.isEmpty) {
        return _ServiceState(
          title: 'Layanan belum bisa dimuat',
          description: error,
          onRetry: controller.fetchServiceCatalog,
        );
      }

      final groups = controller.groupedServices;
      final selectedGroup = controller.selectedServiceCategory;
      if (groups.isEmpty || selectedGroup == null) {
        return _ServiceState(
          title: 'Belum ada layanan',
          description: 'Katalog layanan pasien akan tampil di sini.',
          onRetry: controller.fetchServiceCatalog,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layanan kesehatan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: groups
                  .map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: group.key == selectedGroup.key,
                        label: Text(group.name),
                        avatar: Icon(
                          _categoryIcon(group.icon, group.name),
                          size: 18,
                        ),
                        onSelected: (_) =>
                            controller.selectServiceCategory(group),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedGroup.services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.24,
            ),
            itemBuilder: (context, index) => _ServiceCard(
              service: selectedGroup.services[index],
              onTap: () => controller.openMatchmakingForService(
                selectedGroup.services[index],
              ),
            ),
          ),
        ],
      );
    });
  }

  IconData _categoryIcon(String? rawIcon, String name) {
    final icon = rawIcon?.toLowerCase().trim() ?? name.toLowerCase();
    if (icon.contains('heart') || icon.contains('nurse')) {
      return Icons.health_and_safety_rounded;
    }
    if (icon.contains('doctor') || icon.contains('medical')) {
      return Icons.medical_services_rounded;
    }
    if (icon.contains('home')) {
      return Icons.home_repair_service_rounded;
    }
    if (icon.contains('chat')) {
      return Icons.chat_bubble_rounded;
    }
    return Icons.local_hospital_rounded;
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final ServiceBookingServiceEntity service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = CurrencyFormatter.formatRupiahFromString(
      service.price,
      emptyValue: 'Harga menyesuaikan',
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7E1D8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              service.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceState extends StatelessWidget {
  const _ServiceState({
    required this.title,
    required this.description,
    required this.onRetry,
  });

  final String title;
  final String description;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E1D8)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(description, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}

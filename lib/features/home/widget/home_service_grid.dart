import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../service_booking/domain/entities/service_booking_service_entity.dart';
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
              childAspectRatio: 1.02,
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
    final imageUrl = _resolveImageUrl(service.image);
    developer.log(
      'build service card serviceId=${service.bookingServiceId} '
      'name="${service.name}" rawImage="${service.image}" resolvedImage="$imageUrl"',
      name: 'image-show',
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE9EFEA)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF244235).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ServiceImage(imageUrl: imageUrl),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                service.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF24352D),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  height: 1.18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      developer.log(
        'fallback icon: image is empty for serviceId=${service.bookingServiceId} '
        'name="${service.name}"',
        name: 'image-show',
      );
      return null;
    }

    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      developer.log(
        'fallback icon: invalid image uri for serviceId=${service.bookingServiceId} '
        'name="${service.name}" rawImage="$rawUrl"',
        name: 'image-show',
      );
      return null;
    }

    if (uri.hasScheme) {
      return uri.toString();
    }

    final trimmedUrl = rawUrl.trim();
    final normalizedPath = _normalizeServiceImagePath(trimmedUrl);
    final resolvedUrl = '${AppConfig.baseUrl}$normalizedPath';
    developer.log(
      'resolved relative image for serviceId=${service.bookingServiceId} '
      'name="${service.name}" rawImage="$rawUrl" resolvedImage="$resolvedUrl"',
      name: 'image-show',
    );
    return resolvedUrl;
  }

  String _normalizeServiceImagePath(String rawUrl) {
    if (rawUrl.startsWith('/storage/')) {
      return rawUrl;
    }

    final withoutLeadingSlash = rawUrl.startsWith('/')
        ? rawUrl.substring(1)
        : rawUrl;

    if (withoutLeadingSlash.startsWith('storage/')) {
      return '/$withoutLeadingSlash';
    }

    if (withoutLeadingSlash.startsWith('services/')) {
      return '/storage/$withoutLeadingSlash';
    }

    return '/storage/services/$withoutLeadingSlash';
  }
}

class _ServiceImage extends StatelessWidget {
  const _ServiceImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const fallback = _ServiceFallbackIcon();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 92,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF8),
          border: Border.all(color: const Color(0xFFE7F0EA)),
        ),
        child: imageUrl == null
            ? fallback
            : Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, error, stackTrace) {
                  developer.log(
                    'image network error url="$imageUrl"',
                    name: 'image-show',
                    error: error,
                    stackTrace: stackTrace,
                  );
                  return fallback;
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    developer.log(
                      'image loaded url="$imageUrl"',
                      name: 'image-show',
                    );
                    return child;
                  }

                  developer.log(
                    'image loading url="$imageUrl" '
                    'loaded=${progress.cumulativeBytesLoaded} '
                    'total=${progress.expectedTotalBytes}',
                    name: 'image-show',
                  );
                  return fallback;
                },
              ),
      ),
    );
  }
}

class _ServiceFallbackIcon extends StatelessWidget {
  const _ServiceFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_hospital_rounded,
        color: AppColors.primary,
        size: 28,
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

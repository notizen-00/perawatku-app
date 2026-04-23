import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/nurse_entity.dart';
import '../controllers/nurse_controller.dart';

class NursePage extends GetView<NurseController> {
  const NursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perawat'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.nurses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.nurses.isEmpty) {
          return _StateMessage(
            title: 'Perawat belum bisa dimuat',
            description: controller.errorMessage.value!,
            actionLabel: 'Coba lagi',
            onTap: controller.loadNurses,
          );
        }

        if (controller.nurses.isEmpty) {
          return const _StateMessage(
            title: 'Belum ada perawat',
            description: 'Data perawat yang tersedia akan tampil di halaman ini.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadNurses(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.nurses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final nurse = controller.nurses[index];
              return _NurseListCard(nurse: nurse);
            },
          ),
        );
      }),
    );
  }
}

class _NurseListCard extends StatelessWidget {
  const _NurseListCard({
    required this.nurse,
  });

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
  const _ChipLabel({
    required this.icon,
    required this.label,
  });

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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onTap != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onTap,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

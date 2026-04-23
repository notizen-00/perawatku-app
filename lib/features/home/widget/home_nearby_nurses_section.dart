import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/home_controller.dart';
import '../data/models/nurse_model.dart';

class HomeNearbyNursesSection extends StatelessWidget {
  const HomeNearbyNursesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF1994E6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'List Perawat terdekat',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            TextButton(
              onPressed: controller.fetchNearbyNurses,
              child: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (controller.isLoadingNurses.value &&
              controller.nearbyNurses.isEmpty) {
            return const _NearbyNursesLoading();
          }

          final errorMessage = controller.nurseErrorMessage.value;
          if (errorMessage != null && controller.nearbyNurses.isEmpty) {
            return _NearbyNursesError(
              message: errorMessage,
              onRetry: controller.fetchNearbyNurses,
            );
          }

          if (controller.nearbyNurses.isEmpty) {
            return const _NearbyNursesEmpty();
          }

          return Column(
            children: List.generate(controller.nearbyNurses.length, (index) {
              final nurse = controller.nearbyNurses[index];
              final accent = _accentFor(index);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == controller.nearbyNurses.length - 1 ? 0 : 12,
                ),
                child: _NurseCard(
                  nurse: nurse,
                  accent: accent,
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Color _accentFor(int index) {
    const accents = [
      Color(0xFF1994E6),
      Color(0xFF13BE41),
      AppColors.primary,
      Color(0xFFF59E0B),
    ];

    return accents[index % accents.length];
  }
}

class _NurseCard extends StatelessWidget {
  const _NurseCard({
    required this.nurse,
    required this.accent,
  });

  final NurseModel nurse;
  final Color accent;

  String _formatDistance(double? distanceKm) {
    if (distanceKm == null) {
      return 'Jarak belum tersedia';
    }

    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String _formatFee(String rawFee) {
    final parsedFee = double.tryParse(rawFee);
    if (parsedFee == null) {
      return 'Biaya belum diatur';
    }

    return 'Rp${parsedFee.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF12211F) : Colors.white;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8);
    final muted = isDark ? AppColors.darkMutedText : AppColors.lightMutedText;
    final partner = nurse.partnerProfile;
    final specialization = (partner?.specialization ?? '').trim().isEmpty
        ? 'Perawat'
        : partner!.specialization;
    final workLocation = (partner?.workLocation ?? '').trim().isEmpty
        ? 'Lokasi kerja belum tersedia'
        : partner!.workLocation;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              color: accent,
              size: 30,
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
                  specialization,
                  style: TextStyle(
                    fontSize: 13,
                    color: muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workLocation,
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.place_rounded,
                      label: _formatDistance(nurse.distanceKm),
                      color: accent,
                    ),
                    _InfoChip(
                      icon: Icons.payments_rounded,
                      label: _formatFee(partner?.consultationFee ?? ''),
                      color: const Color(0xFFF59E0B),
                    ),
                    _InfoChip(
                      icon: partner?.isAvailable == true
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      label: partner?.isAvailable == true
                          ? 'Tersedia'
                          : 'Belum tersedia',
                      color: partner?.isAvailable == true
                          ? const Color(0xFF13BE41)
                          : const Color(0xFFEF4444),
                    ),
                  ],
                ),
                if ((partner?.bio ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    partner!.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyNursesLoading extends StatelessWidget {
  const _NearbyNursesLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sedang memuat daftar perawat di sekitar Anda...',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyNursesError extends StatelessWidget {
  const _NearbyNursesError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar perawat belum bisa dimuat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

class _NearbyNursesEmpty extends StatelessWidget {
  const _NearbyNursesEmpty();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8),
        ),
      ),
      child: const Text(
        'Belum ada perawat yang cocok dengan lokasi atau filter saat ini.',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeNearbyNursesSection extends StatelessWidget {
  const HomeNearbyNursesSection({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text(
              'List Perawat terdekat',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _NurseCard(
          name: 'Suster Amanda Putri',
          specialty: 'Perawatan luka & infus',
          distance: '1.2 km',
          eta: '8 menit',
          rating: '4.9',
          accent: Color(0xFF1994E6),
        ),
        const SizedBox(height: 12),
        const _NurseCard(
          name: 'Suster Dhea Lestari',
          specialty: 'Home care lansia',
          distance: '2.1 km',
          eta: '12 menit',
          rating: '4.8',
          accent: Color(0xFF13BE41),
        ),
        const SizedBox(height: 12),
        const _NurseCard(
          name: 'Suster Fikri Rahman',
          specialty: 'Suntik vitamin & observasi',
          distance: '3.4 km',
          eta: '18 menit',
          rating: '4.7',
          accent: AppColors.primary,
        ),
      ],
    );
  }
}

class _NurseCard extends StatelessWidget {
  const _NurseCard({
    required this.name,
    required this.specialty,
    required this.distance,
    required this.eta,
    required this.rating,
    required this.accent,
  });

  final String name;
  final String specialty;
  final String distance;
  final String eta;
  final String rating;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF12211F) : Colors.white;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8);
    final muted = isDark ? AppColors.darkMutedText : AppColors.lightMutedText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Row(
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
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 13,
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.place_rounded,
                      label: distance,
                      color: accent,
                    ),
                    _InfoChip(
                      icon: Icons.schedule_rounded,
                      label: eta,
                      color: const Color(0xFFEF4444),
                    ),
                    _InfoChip(
                      icon: Icons.star_rounded,
                      label: rating,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
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

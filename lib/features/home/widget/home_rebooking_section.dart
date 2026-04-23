import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeRebookingSection extends StatelessWidget {
  const HomeRebookingSection({super.key});

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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Lebih cepat buat book lagi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _BookingCard(
                title: 'Konsultasi Dokter',
                subtitle: 'Booking cepat untuk keluhan harian Anda.',
                actionLabel: 'Buka Layanan',
                accent: AppColors.primary,
                icon: Icons.medical_services_rounded,
              ),
              SizedBox(width: 14),
              _BookingCard(
                title: 'Perawatan di Rumah',
                subtitle: 'Pesan perawat dan tindakan medis ke rumah.',
                actionLabel: 'Pesan Sekarang',
                accent: Color(0xFF1994E6),
                icon: Icons.health_and_safety_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, height: 1.35),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent, size: 38),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8),
                ),
              ),
            ),
            child: Text(
              actionLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

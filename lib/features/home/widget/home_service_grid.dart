import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeServiceGrid extends StatelessWidget {
  const HomeServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const services = [
      _ServiceItem('Dokter', Icons.medical_services_rounded, 'MURAH!'),
      _ServiceItem('Perawat', Icons.health_and_safety_rounded, '-30rb'),
      _ServiceItem('Caregiver', Icons.volunteer_activism_rounded, '-70%'),
      _ServiceItem('Apotek', Icons.local_shipping_rounded, '5RB!'),
      _ServiceItem('Rawat Luka', Icons.healing_rounded, '30MINS'),
      _ServiceItem('Infus', Icons.water_drop_rounded, '>100JT'),
      _ServiceItem('Tes Lab', Icons.biotech_rounded, '-50%'),
      _ServiceItem('Lainnya', Icons.grid_view_rounded, null),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) => _GridServiceCard(item: services[index]),
    );
  }
}

class _ServiceItem {
  const _ServiceItem(this.label, this.icon, this.badge);

  final String label;
  final IconData icon;
  final String? badge;
}

class _GridServiceCard extends StatelessWidget {
  const _GridServiceCard({required this.item});

  final _ServiceItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12211F) : AppColors.softWhite,
                borderRadius: BorderRadius.circular(22),
                gradient: item.label == 'Lainnya'
                    ? null
                    : LinearGradient(
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.22),
                          AppColors.primary.withValues(alpha: 0.12),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: Icon(
                item.icon,
                size: item.label == 'Lainnya' ? 34 : 32,
                color: item.label == 'Lainnya'
                    ? (isDark ? AppColors.darkText : const Color(0xFF4A4A4A))
                    : AppColors.primary,
              ),
            ),
            if (item.badge != null)
              Positioned(
                top: -6,
                left: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class HomeServiceGrid extends StatelessWidget {
  const HomeServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const services = [
      _ServiceItem('Dokter', Icons.medical_services_rounded),
      _ServiceItem('Perawat', Icons.health_and_safety_rounded),
      _ServiceItem('Peta', Icons.map_rounded, route: AppRoutes.map),
      _ServiceItem('Obat', Icons.medication_liquid_outlined),
      _ServiceItem('Rawat Luka', Icons.healing_rounded),
      _ServiceItem('Infus', Icons.water_drop_rounded),
      _ServiceItem('Tes Lab', Icons.biotech_rounded),
      _ServiceItem('Lainnya', Icons.grid_view_rounded),
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
  const _ServiceItem(this.label, this.icon, {this.route});

  final String label;
  final IconData icon;
  final String? route;
}

class _GridServiceCard extends StatelessWidget {
  const _GridServiceCard({required this.item});

  final _ServiceItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routeName =
        item.route ??
        switch (item.label) {
          'Dokter' => AppRoutes.doctors,
          'Perawat' => AppRoutes.nurses,
          _ => null,
        };

    return InkWell(
      onTap: routeName == null ? null : () => Get.toNamed(routeName),
      borderRadius: BorderRadius.circular(22),
      child: Column(
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
          const SizedBox(height: 8),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeGreenPromoBanner extends StatelessWidget {
  const HomeGreenPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF103130), Color(0xFF116A67), Color(0xFF18A59F)]
              : const [Color(0xFFDDFBF2), Color(0xFFB7F5E1), Color(0xFF86E8CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFCDEFE4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi saat ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0E4944),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Jl. Melati No. 18, Kebayoran Baru, Jakarta Selatan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C6D67),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Ubah titik lokasi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.place_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
                Positioned(
                  bottom: 12,
                  child: Icon(
                    Icons.my_location_rounded,
                    size: 18,
                    color: Color(0xFFEF4444),
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

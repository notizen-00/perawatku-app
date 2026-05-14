import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeHeroPromo extends StatelessWidget {
  const HomeHeroPromo({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 186,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFBA1F28), Color(0xFFD63A44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'SEHAT HEMAT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 12,
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 0,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sehat bareng pakai',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        color: Color(0xFFFF4D67),
                        size: 34,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'HOME\nCARE',
                        style: TextStyle(
                          fontSize: 26,
                          height: 0.95,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 0,
            top: 28,
            child: _HeroIllustration(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 160,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const Positioned(
            left: 6,
            bottom: 20,
            child: _MiniCharacter(
              shirt: Color(0xFFE8B2B8),
              pants: Color(0xFF4E6AD8),
            ),
          ),
          const Positioned(
            left: 52,
            bottom: 28,
            child: _MiniCharacter(
              shirt: Color(0xFFF4E8C9),
              pants: Color(0xFF5B7A4A),
            ),
          ),
          const Positioned(
            right: 10,
            bottom: 18,
            child: _MiniCharacter(
              shirt: Color(0xFFD7E6FF),
              pants: Color(0xFF6B4B30),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCharacter extends StatelessWidget {
  const _MiniCharacter({required this.shirt, required this.pants});

  final Color shirt;
  final Color pants;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 98,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 18,
            child: Container(
              width: 42,
              height: 40,
              decoration: BoxDecoration(
                color: shirt,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFF5CDAA),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 52,
            child: Container(
              width: 24,
              height: 34,
              decoration: BoxDecoration(
                color: pants,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

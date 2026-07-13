import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeHeroPromo extends StatefulWidget {
  const HomeHeroPromo({super.key, required this.isDark});

  final bool isDark;

  @override
  State<HomeHeroPromo> createState() => _HomeHeroPromoState();
}

class _HomeHeroPromoState extends State<HomeHeroPromo> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<_HeroPromoData> _promos = [
    _HeroPromoData(
      badge: 'SEHAT HEMAT',
      title: 'Layanan di rumah',
      subtitle: 'Perawat datang ke rumah untuk bantu pemulihan keluarga.',
      icon: Icons.groups_rounded,
      gradient: [Color(0xFFBA1F28), Color(0xFFD63A44)],
      accent: Color(0xFFD2DC02),
    ),
    _HeroPromoData(
      badge: 'CHAT DOKTER',
      title: 'Konsultasi cepat',
      subtitle: 'Tulis gejala, bayar, lalu lanjut obrolan dengan dokter.',
      icon: Icons.chat_bubble_rounded,
      gradient: [Color(0xFF047D78), Color(0xFF12B8A8)],
      accent: Color(0xFFFFD166),
    ),
    _HeroPromoData(
      badge: 'APOTIK ONLINE',
      title: 'Obat diantar',
      subtitle: 'Cari kebutuhan obat dan pantau status pesanan dari aplikasi.',
      icon: Icons.medication_rounded,
      gradient: [Color(0xFF3154A3), Color(0xFF5E8BFF)],
      accent: Color(0xFFFFB3C1),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 214,
      child: Column(
        children: [
          SizedBox(
            height: 186,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _promos.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == _promos.length - 1 ? 0 : 10,
                  ),
                  child: _HeroPromoCard(
                    promo: _promos[index],
                    isDark: widget.isDark,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _promos.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _currentIndex == index ? 22 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPromoCard extends StatelessWidget {
  const _HeroPromoCard({required this.promo, required this.isDark});

  final _HeroPromoData promo;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: promo.gradient,
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
                color: promo.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                promo.badge,
                style: const TextStyle(
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
              width: 238,
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(promo.icon, color: promo.gradient.last, size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          promo.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 21,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          promo.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 0,
            top: 28,
            child: _HeroIllustration(accent: promo.accent, icon: promo.icon),
          ),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.accent, required this.icon});

  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 146,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 14,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 20,
            child: _MiniCharacter(
              shirt: accent.withValues(alpha: 0.88),
              pants: const Color(0xFF4E6AD8),
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
            right: 4,
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

class _HeroPromoData {
  const _HeroPromoData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accent,
  });

  final String badge;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;
}

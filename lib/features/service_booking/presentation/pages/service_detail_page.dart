import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/controller/home_controller.dart';
import '../../domain/entities/service_booking_service_entity.dart';

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.arguments;
    if (service is! ServiceBookingServiceEntity) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Layanan')),
        body: const Center(child: Text('Data layanan tidak tersedia.')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFF8FBFA);
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor =
        isDark ? AppColors.darkMutedText : AppColors.lightMutedText;
    final price = CurrencyFormatter.formatRupiahFromString(
      service.price,
      emptyValue: 'Menyesuaikan',
    );
    final imageUrl = _resolveImageUrl(service.image, service);
    final category = _categoryLabel(service);
    final duration = _durationLabel(service.estimatedDuration);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        centerTitle: true,
        title: Text(
          service.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Bagikan',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 18),
              children: [
                _ServiceHero(
                  serviceName: service.name,
                  category: category,
                  imageUrl: imageUrl,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryCard(
                        price: price,
                        duration: duration,
                        category: category,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Deskripsi Layanan',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _description(service),
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 15.5,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _RequirementTile(
                        icon: Icons.location_on_rounded,
                        title: service.requiresAddress
                            ? 'Perlu alamat'
                            : 'Alamat opsional',
                        subtitle: service.requiresAddress
                            ? 'Pastikan lokasi layanan akurat'
                            : 'Alamat dapat dilengkapi bila dibutuhkan',
                      ),
                      const SizedBox(height: 12),
                      _RequirementTile(
                        icon: Icons.calendar_month_rounded,
                        title: service.requiresSchedule
                            ? 'Perlu jadwal'
                            : 'Jadwal fleksibel',
                        subtitle: service.requiresSchedule
                            ? 'Pilih waktu kunjungan'
                            : 'Tim akan menyesuaikan ketersediaan',
                      ),
                      const SizedBox(height: 12),
                      _RequirementTile(
                        icon: Icons.manage_accounts_rounded,
                        title: service.requiresMatchmaking
                            ? 'Mitra dipilih otomatis'
                            : 'Layanan siap diproses',
                        subtitle: service.requiresMatchmaking
                            ? 'Mitra terdekat dan aktif akan dicari'
                            : 'Pesanan diproses sesuai detail layanan',
                      ),
                      const SizedBox(height: 24),
                      const _PreparationCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _BottomOrderBar(
            price: price,
            onPressed: () => _orderService(service),
          ),
        ],
      ),
    );
  }

  static void _orderService(ServiceBookingServiceEntity service) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().proceedWithServiceBooking(service);
      if (Get.currentRoute == AppRoutes.serviceDetail) {
        Get.back();
      }
      return;
    }

    Get.offAllNamed(AppRoutes.home);
  }

  static String _categoryLabel(ServiceBookingServiceEntity service) {
    final label = service.categoryName ?? service.category ?? 'Layanan';
    return label.trim().isEmpty ? 'Layanan' : label.trim();
  }

  static String _description(ServiceBookingServiceEntity service) {
    final description = service.description?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }

    return '${service.name} membantu pasien mendapatkan layanan kesehatan '
        'dengan pendampingan tenaga kesehatan sesuai kebutuhan di rumah.';
  }

  static String _durationLabel(String? rawDuration) {
    final raw = rawDuration?.trim();
    if (raw == null || raw.isEmpty) {
      return '-';
    }

    final minutes = num.tryParse(raw);
    if (minutes == null) {
      return raw;
    }

    return '${minutes.toInt()} mins';
  }

  static String? _resolveImageUrl(
    String? rawUrl,
    ServiceBookingServiceEntity service,
  ) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      developer.log(
        'detail fallback: image is empty serviceId=${service.bookingServiceId}',
        name: 'image-show',
      );
      return null;
    }

    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      return null;
    }

    if (uri.hasScheme) {
      return uri.toString();
    }

    final normalizedPath = _normalizeServiceImagePath(rawUrl.trim());
    final resolvedUrl = '${AppConfig.baseUrl}$normalizedPath';
    developer.log(
      'detail resolved image serviceId=${service.bookingServiceId} '
      'rawImage="$rawUrl" resolvedImage="$resolvedUrl"',
      name: 'image-show',
    );
    return resolvedUrl;
  }

  static String _normalizeServiceImagePath(String rawUrl) {
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

class _ServiceHero extends StatelessWidget {
  const _ServiceHero({
    required this.serviceName,
    required this.category,
    required this.imageUrl,
  });

  final String serviceName;
  final String category;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(
          Icons.local_hospital_rounded,
          color: AppColors.primary,
          size: 72,
        ),
      ),
    );

    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl == null
              ? fallback
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallback,
                ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.62),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  serviceName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.price,
    required this.duration,
    required this.category,
  });

  final String price;
  final String duration;
  final String category;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final backgroundColor = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: const Color(0xFF244235).withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Wrap(
        runSpacing: 18,
        children: [
          _SummaryItem(label: 'Harga Layanan', value: price),
          _SummaryItem(
            label: 'Durasi Est.',
            value: duration,
            icon: Icons.schedule_rounded,
          ),
          _SummaryItem(
            label: 'Kategori',
            value: category,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 72) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: AppColors.primary),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor ?? AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequirementTile extends StatelessWidget {
  const _RequirementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.lightMutedText,
                    fontWeight: FontWeight.w600,
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

class _PreparationCard extends StatelessWidget {
  const _PreparationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Persiapan Pasien',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _PreparationItem(
            'Sediakan tempat yang tenang dengan pencahayaan cukup.',
          ),
          _PreparationItem(
            'Gunakan pakaian yang nyaman dan mudah disesuaikan.',
          ),
          _PreparationItem(
            'Siapkan dokumen medis atau riwayat alergi jika ada.',
          ),
        ],
      ),
    );
  }
}

class _PreparationItem extends StatelessWidget {
  const _PreparationItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomOrderBar extends StatelessWidget {
  const _BottomOrderBar({
    required this.price,
    required this.onPressed,
  });

  final String price;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Estimasi',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.lightMutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              height: 58,
              child: FilledButton(
                onPressed: onPressed,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pesan Layanan',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

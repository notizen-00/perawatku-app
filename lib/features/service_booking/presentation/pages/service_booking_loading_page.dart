import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/service_booking_entity.dart';
import '../controllers/service_booking_controller.dart';

class ServiceBookingLoadingPage extends StatelessWidget {
  const ServiceBookingLoadingPage({
    super.key,
    this.title = 'Menunggu konfirmasi mitra',
    this.subtitle =
        'Kami mencarikan mitra yang sesuai. Jika mitra menolak, sistem otomatis mencari pengganti.',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFF8FBFA);
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor =
        isDark ? AppColors.darkMutedText : AppColors.lightMutedText;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Lottie.asset(
                    'assets/medic-loading.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 14),
                _LoadingStatusText(
                  fallbackTitle: title,
                  fallbackSubtitle: subtitle,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                const SizedBox(height: 24),
                const _LoadingSteps(),
                const Spacer(),
                Text(
                  'Mohon tunggu sebentar, jangan tutup aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingStatusText extends StatelessWidget {
  const _LoadingStatusText({
    required this.fallbackTitle,
    required this.fallbackSubtitle,
    required this.textColor,
    required this.mutedColor,
  });

  final String fallbackTitle;
  final String fallbackSubtitle;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ServiceBookingController>()) {
      return _StatusCopy(
        title: fallbackTitle,
        subtitle: fallbackSubtitle,
        textColor: textColor,
        mutedColor: mutedColor,
      );
    }

    final controller = Get.find<ServiceBookingController>();
    return Obx(() {
      final booking = controller.latestBooking.value;
      final isRematching = controller.isRematchingPartner.value;
      return _StatusCopy(
        title: _titleFor(booking, isRematching: isRematching),
        subtitle: _subtitleFor(booking, isRematching: isRematching),
        textColor: textColor,
        mutedColor: mutedColor,
      );
    });
  }

  String _titleFor(
    ServiceBookingEntity? booking, {
    required bool isRematching,
  }) {
    if (isRematching) {
      return 'Mencari mitra baru';
    }
    if (booking == null) {
      return fallbackTitle;
    }
    if (booking.isSearchingReplacementPartner) {
      return 'Mencari mitra pengganti';
    }
    if (booking.isWaitingPartnerAcceptance) {
      return 'Menunggu konfirmasi mitra';
    }
    return fallbackTitle;
  }

  String _subtitleFor(
    ServiceBookingEntity? booking, {
    required bool isRematching,
  }) {
    if (isRematching) {
      return 'Mitra sebelumnya belum menerima. Kami sedang mencarikan mitra pengganti.';
    }
    if (booking == null) {
      return fallbackSubtitle;
    }
    if (booking.isSearchingReplacementPartner) {
      return 'Mitra sebelumnya belum menerima. Sistem sedang mencari mitra lain dan memperbarui estimasi biaya.';
    }
    if (booking.isWaitingPartnerAcceptance) {
      return 'Mitra kandidat sudah ditemukan. Kami menunggu mitra menerima pesanan sebelum lanjut ke pembayaran.';
    }
    return fallbackSubtitle;
  }
}

class _StatusCopy extends StatelessWidget {
  const _StatusCopy({
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.mutedColor,
  });

  final String title;
  final String subtitle;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 26,
            height: 1.14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: mutedColor,
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LoadingSteps extends StatelessWidget {
  const _LoadingSteps();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ServiceBookingController>()) {
      return const Column(
        children: [
          _LoadingStep(text: 'Memvalidasi jadwal dan data pasien'),
          SizedBox(height: 8),
          _LoadingStep(text: 'Menghitung estimasi biaya layanan'),
          SizedBox(height: 8),
          _LoadingStep(text: 'Menunggu mitra menerima pesanan'),
        ],
      );
    }

    final controller = Get.find<ServiceBookingController>();
    return Obx(() {
      final booking = controller.latestBooking.value;
      final isRematching = controller.isRematchingPartner.value;
      final lastStep = isRematching
          ? 'Mengirim permintaan cari mitra baru'
          : booking?.isSearchingReplacementPartner == true
          ? 'Mencari mitra pengganti yang tersedia'
          : 'Menunggu mitra menerima pesanan';

      return Column(
        children: [
          const _LoadingStep(text: 'Memvalidasi jadwal dan data pasien'),
          const SizedBox(height: 8),
          const _LoadingStep(text: 'Menghitung estimasi biaya layanan'),
          const SizedBox(height: 8),
          _LoadingStep(text: lastStep),
        ],
      );
    });
  }
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

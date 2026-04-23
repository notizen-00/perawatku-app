import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/doctor_entity.dart';
import '../controllers/doctor_controller.dart';

class DoctorPage extends GetView<DoctorController> {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokter'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.doctors.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.doctors.isEmpty) {
          return _DoctorStateMessage(
            title: 'Dokter belum bisa dimuat',
            description: controller.errorMessage.value!,
            actionLabel: 'Coba lagi',
            onTap: controller.loadDoctors,
          );
        }

        if (controller.doctors.isEmpty) {
          return const _DoctorStateMessage(
            title: 'Belum ada dokter',
            description: 'Daftar dokter akan muncul di halaman ini.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadDoctors(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.doctors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doctor = controller.doctors[index];
              return _DoctorCard(doctor: doctor);
            },
          ),
        );
      }),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
  });

  final DoctorEntity doctor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = doctor.profile;
    final photoUrl = _resolvePhotoUrl(profile?.photoUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: photoUrl == null
                      ? Container(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          alignment: Alignment.center,
                          child: const Icon(Icons.person_rounded, size: 34),
                        )
                      : Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            alignment: Alignment.center,
                            child: const Icon(Icons.person_rounded, size: 34),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (profile?.specialization ?? '').trim().isEmpty
                          ? 'Dokter'
                          : profile!.specialization,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightMutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.formatRupiahFromString(
                        profile?.consultationFee,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (profile?.workLocation ?? '').trim().isEmpty
                          ? 'Lokasi praktik belum tersedia'
                          : profile!.workLocation,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightMutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.doctorChat,
                      arguments: doctor,
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_rounded),
                  label: const Text('Konsultasi Chat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _resolvePhotoUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      return null;
    }

    if (uri.hasScheme) {
      return uri.toString();
    }

    final normalizedPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
    return '${AppConfig.baseUrl}$normalizedPath';
  }
}

class _DoctorStateMessage extends StatelessWidget {
  const _DoctorStateMessage({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onTap != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onTap,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

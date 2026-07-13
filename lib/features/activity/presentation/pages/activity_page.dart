import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/activity_record_entity.dart';
import '../../domain/usecases/get_consultation_activities_use_case.dart';
import '../../domain/usecases/get_medicine_purchase_activities_use_case.dart';
import '../../domain/usecases/get_other_activities_use_case.dart';
import '../../../doctor/presentation/models/doctor_chat_arguments.dart';
import '../controllers/activity_controller.dart';

class ActivityPage extends StatelessWidget {
  ActivityPage({super.key});

  final ActivityController controller = Get.isRegistered<ActivityController>()
      ? Get.find<ActivityController>()
      : Get.put(
          ActivityController(
            getConsultationActivitiesUseCase:
                Get.find<GetConsultationActivitiesUseCase>(),
            getMedicinePurchaseActivitiesUseCase:
                Get.find<GetMedicinePurchaseActivitiesUseCase>(),
            getOtherActivitiesUseCase: Get.find<GetOtherActivitiesUseCase>(),
          ),
        );

  static const List<String> _monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFF5F7FB);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Obx(() {
            return Column(
              children: [
                _ActivityHeader(
                  isDark: isDark,
                  onRefresh: controller.isLoading.value
                      ? null
                      : controller.loadActivities,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF12211F) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                      ),
                    ),
                    child: const TabBar(
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(text: 'Konsultasi'),
                        Tab(text: 'Layanan'),
                        Tab(text: 'Lainnya'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _buildBody(context, isDark),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    if (controller.isLoading.value &&
        controller.consultationActivities.isEmpty &&
        controller.medicineActivities.isEmpty &&
        controller.otherActivities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.value != null &&
        controller.consultationActivities.isEmpty) {
      return _ActivityStateMessage(
        title: 'Aktivitas belum bisa dimuat',
        description: controller.errorMessage.value!,
        actionLabel: 'Coba lagi',
        onTap: controller.loadActivities,
      );
    }

    return TabBarView(
      children: [
        _ActivityListTab(
          records: controller.consultationActivities,
          emptyTitle: 'Belum ada riwayat konsultasi',
          emptyDescription:
              'Aktivitas obrolan dokter dan layanan konsultasi akan muncul di sini.',
          icon: Icons.medical_information_rounded,
          isDark: isDark,
          formatDate: _formatDate,
          statusStyle: _statusStyle,
        ),
        _ActivityListTab(
          records: controller.otherActivities,
          emptyTitle: 'Belum ada pesanan layanan',
          emptyDescription:
              'Pesanan layanan di rumah dan layanan medis akan tampil di tab ini.',
          icon: Icons.home_repair_service_rounded,
          isDark: isDark,
          formatDate: _formatDate,
          statusStyle: _statusStyle,
        ),
        _ActivityListTab(
          records: controller.medicineActivities,
          emptyTitle: 'Belum ada aktivitas lain',
          emptyDescription:
              'Aktivitas medis lain yang belum masuk kategori layanan akan tampil di sini.',
          icon: Icons.inventory_2_rounded,
          isDark: isDark,
          formatDate: _formatDate,
          statusStyle: _statusStyle,
        ),
      ],
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _monthNames[local.month];
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  _ActivityStatusStyle _statusStyle(String rawStatus) {
    final status = rawStatus.toLowerCase();

    if (status == 'active' ||
        status == 'confirmed' ||
        status == 'ongoing' ||
        status == 'opened') {
      return const _ActivityStatusStyle(
        label: 'Aktif',
        color: AppColors.info,
      );
    }

    if (status == 'pending' ||
        status == 'processing' ||
        status == 'scheduled') {
      return const _ActivityStatusStyle(
        label: 'Menunggu',
        color: AppColors.warning,
      );
    }

    if (status == 'paid' ||
        status == 'settlement' ||
        status == 'capture' ||
        status == 'success') {
      return const _ActivityStatusStyle(
        label: 'Terbayar',
        color: AppColors.success,
      );
    }

    if (status == 'completed' || status == 'delivered' || status == 'done') {
      return const _ActivityStatusStyle(
        label: 'Selesai',
        color: AppColors.success,
      );
    }

    if (status == 'cancel' ||
        status == 'cancelled' ||
        status == 'deny' ||
        status == 'expired' ||
        status == 'failed') {
      return const _ActivityStatusStyle(
        label: 'Gagal',
        color: AppColors.error,
      );
    }

    return const _ActivityStatusStyle(
      label: 'Diproses',
      color: AppColors.info,
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({
    required this.isDark,
    required this.onRefresh,
  });

  final bool isDark;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF103633), Color(0xFF0E6B65)]
              : const [Color(0xFFDDF6C8), Color(0xFF7EE6D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktivitas Pasien',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF113331),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pantau riwayat konsultasi, pesanan layanan, dan aktivitas medis Anda dalam satu tempat.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF204B48),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _ActivityListTab extends StatelessWidget {
  const _ActivityListTab({
    required this.records,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.icon,
    required this.isDark,
    required this.formatDate,
    required this.statusStyle,
  });

  final List<ActivityRecordEntity> records;
  final String emptyTitle;
  final String emptyDescription;
  final IconData icon;
  final bool isDark;
  final String Function(DateTime? dateTime) formatDate;
  final _ActivityStatusStyle Function(String rawStatus) statusStyle;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _ActivityStateMessage(
        title: emptyTitle,
        description: emptyDescription,
        icon: icon,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        final status = statusStyle(record.status);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: record.canOpenConsultation
                ? () {
                    Get.toNamed(
                      record.canOpenChat
                          ? AppRoutes.doctorChat
                          : AppRoutes.doctorConsultation,
                      arguments: DoctorChatArguments(
                        consultationId: record.consultationId,
                        partnerUserId: record.partnerUserId,
                        doctorName: record.doctorName,
                        specialization: record.specialization,
                        doctorPhotoUrl: record.doctorPhotoUrl,
                      ),
                    );
                  }
                : record.canOpenServiceBooking
                    ? () {
                        Get.toNamed(
                          AppRoutes.serviceBookingDetail,
                          arguments: {'bookingId': int.tryParse(record.id)},
                        );
                      }
                    : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF12211F) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              record.subtitle,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkMutedText
                                    : AppColors.lightMutedText,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              record.amountLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: status.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status.label,
                              style: TextStyle(
                                color: status.color,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (record.canOpenConsultation ||
                              record.canOpenServiceBooking) ...[
                            const SizedBox(height: 10),
                            Text(
                              record.canOpenServiceBooking
                                  ? 'Lihat detail'
                                  : record.canOpenChat
                                      ? 'Buka obrolan'
                                      : 'Lihat konsultasi',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightMutedText,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          formatDate(record.dateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkMutedText
                                : AppColors.lightMutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActivityStateMessage extends StatelessWidget {
  const _ActivityStateMessage({
    required this.title,
    required this.description,
    this.icon = Icons.receipt_long_rounded,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
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
            Icon(icon, size: 42, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            if (actionLabel != null && onTap != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onTap, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityStatusStyle {
  const _ActivityStatusStyle({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}

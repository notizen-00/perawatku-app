import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../activity/domain/entities/activity_record_entity.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../doctor/presentation/models/doctor_chat_arguments.dart';
import '../controller/home_controller.dart';

class ActiveOrderStatusOverlay extends StatelessWidget {
  const ActiveOrderStatusOverlay({
    super.key,
    required this.activityController,
    required this.homeController,
  });

  final ActivityController activityController;
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeOrder = activityController.visibleActiveOrder;
      if (activeOrder == null) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: _ActiveOrderCard(
          record: activeOrder,
          onTap: () => _openActiveOrder(activeOrder),
          onDismiss: activityController.dismissActiveOrderOverlay,
        ),
      );
    });
  }

  void _openActiveOrder(ActivityRecordEntity record) {
    if (record.canOpenConsultation) {
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
      return;
    }

    homeController.selectBottomNav(1);
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({
    required this.record,
    required this.onTap,
    required this.onDismiss,
  });

  final ActivityRecordEntity record;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = _statusStyle(record.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 74),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF10211F) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _categoryIcon(record.category),
                  color: status.color,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: status.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: status.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (record.amountLabel.trim().isNotEmpty &&
                            record.amountLabel != '-') ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              record.amountLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      record.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightMutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onDismiss,
                tooltip: 'Sembunyikan',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.lightMutedText,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'consultation':
        return Icons.chat_bubble_rounded;
      case 'medicine':
        return Icons.medication_rounded;
      default:
        return Icons.local_hospital_rounded;
    }
  }

  _StatusStyle _statusStyle(String rawStatus) {
    final status = rawStatus.toLowerCase();

    if (status == 'active' ||
        status == 'confirmed' ||
        status == 'ongoing' ||
        status == 'opened') {
      return const _StatusStyle('Sedang berjalan', AppColors.info);
    }

    if (status == 'treatment' ||
        status == 'ditangani' ||
        status == 'di tangani') {
      return const _StatusStyle('Ditangani', AppColors.primary);
    }

    if (status == 'pending' ||
        status == 'processing' ||
        status == 'scheduled') {
      return const _StatusStyle('Diproses', AppColors.warning);
    }

    if (status == 'paid' ||
        status == 'settlement' ||
        status == 'capture' ||
        status == 'success' ||
        status == 'approved') {
      return const _StatusStyle('Siap dilanjutkan', AppColors.success);
    }

    return const _StatusStyle('Pesanan aktif', AppColors.primary);
  }
}

class _StatusStyle {
  const _StatusStyle(this.label, this.color);

  final String label;
  final Color color;
}

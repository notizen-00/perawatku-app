import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_entity.dart';
import '../controllers/notification_controller.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : const Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.unreadCount.value == 0
                  ? null
                  : controller.markAllAsRead,
              child: const Text('Baca semua'),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.notifications.isEmpty) {
          return _NotificationStateMessage(
            title: 'Notifikasi belum bisa dimuat',
            description: controller.errorMessage.value!,
            actionLabel: 'Coba lagi',
            onTap: () => controller.refreshNotifications(showLoading: true),
          );
        }

        if (controller.notifications.isEmpty) {
          return const _NotificationStateMessage(
            title: 'Belum ada notifikasi',
            description:
                'Info konsultasi, layanan, dan pesan baru akan muncul di sini.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _NotificationTile(
                notification: notification,
                isDark: isDark,
                onTap: () => controller.openNotification(notification),
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  final NotificationEntity notification;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _typeStyle(notification.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12211F) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isUnread
                  ? style.color.withValues(alpha: 0.42)
                  : isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(style.icon, color: style.color, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                              fontWeight: notification.isUnread
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (notification.isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: style.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.35,
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightMutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightMutedText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _NotificationTypeStyle _typeStyle(String type) {
    if (type.startsWith('consultation.')) {
      return const _NotificationTypeStyle(
        Icons.medical_information_rounded,
        AppColors.info,
      );
    }

    if (type.startsWith('service_booking.')) {
      return const _NotificationTypeStyle(
        Icons.local_hospital_rounded,
        AppColors.primary,
      );
    }

    return const _NotificationTypeStyle(
      Icons.notifications_active_rounded,
      AppColors.warning,
    );
  }

  String _formatDate(String value) {
    final dateTime = DateTime.tryParse(value);
    if (dateTime == null) {
      return value;
    }

    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

class _NotificationTypeStyle {
  const _NotificationTypeStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}

class _NotificationStateMessage extends StatelessWidget {
  const _NotificationStateMessage({
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
            const Icon(
              Icons.notifications_none_rounded,
              size: 44,
              color: AppColors.primary,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../consultation/domain/entities/consultation_entity.dart';
import '../../../consultation/domain/entities/consultation_message_entity.dart';
import '../controllers/doctor_chat_controller.dart';

class DoctorChatPage extends GetView<DoctorChatController> {
  const DoctorChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.consultationTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.consultation.value == null
                  ? null
                  : () => _showPaymentInfoSheet(context),
              icon: const Icon(Icons.receipt_long_rounded),
            ),
          ),
          Obx(
            () => IconButton(
              onPressed: controller.isRefreshing.value
                  ? null
                  : controller.refreshConsultation,
              icon: controller.isRefreshing.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isInitializing.value &&
            controller.consultation.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.consultation.value == null) {
          return _ChatStateMessage(
            title: 'Chat belum siap',
            description: controller.errorMessage.value!,
            actionLabel: 'Coba lagi',
            onTap: controller.initializeConsultation,
          );
        }

        final consultation = controller.consultation.value;
        if (consultation == null) {
          return const _ChatStateMessage(
            title: 'Konsultasi belum tersedia',
            description: 'Silakan buka ulang konsultasi Anda.',
          );
        }

        if (!consultation.isPaid) {
          return _ChatStateMessage(
            title: 'Pembayaran belum selesai',
            description:
                'Halaman chat akan terbuka penuh setelah konsultasi berhasil dibayar.',
            actionLabel: 'Buka pembayaran',
            onTap: () {
              Get.offNamed(
                AppRoutes.doctorConsultation,
                arguments: Get.arguments,
              );
            },
          );
        }

        return Column(
          children: [
            _ChatHeader(controller: controller, consultation: consultation),
            Expanded(
              child: _MessageList(
                doctorPhotoUrl: controller.doctorPhotoUrl,
                messages: controller.messages,
                isMine: controller.isMine,
                scrollController: controller.messageScrollController,
              ),
            ),
            _Composer(controller: controller),
          ],
        );
      }),
    );
  }

  void _showPaymentInfoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Info pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _PaymentInfoRow(
                label: 'Kode konsultasi',
                value: controller.consultationTitle,
              ),
              const SizedBox(height: 10),
              _PaymentInfoRow(
                label: 'Status konsultasi',
                value: controller.consultationStatusLabel,
              ),
              const SizedBox(height: 10),
              _PaymentInfoRow(
                label: 'Status pembayaran',
                value: controller.paymentStatusLabel,
              ),
              const SizedBox(height: 10),
              _PaymentInfoRow(
                label: 'Referensi',
                value: controller.paymentReferenceLabel,
              ),
              const SizedBox(height: 10),
              _PaymentInfoRow(
                label: 'Metode bayar',
                value: controller.paymentMethodLabel,
              ),
              const SizedBox(height: 10),
              _PaymentInfoRow(
                label: 'Biaya',
                value: controller.consultationFeeLabel,
              ),
              const SizedBox(height: 10),
              _PaymentInfoRow(
                label: 'Dibayar pada',
                value: controller.paidAtLabel,
              ),
              const SizedBox(height: 10),
              _PaymentInfoRow(
                label: 'Catatan',
                value: controller.paymentNotesLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.controller, required this.consultation});

  final DoctorChatController controller;
  final ConsultationEntity consultation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _InfoPill(
            icon: Icons.medical_services_rounded,
            label: controller.specializationLabel,
          ),
          _InfoPill(
            icon: Icons.check_circle_rounded,
            label: 'Konsultasi aktif',
            color: AppColors.success,
          ),
          _InfoPill(
            icon: Icons.payments_rounded,
            label: controller.consultationFeeLabel,
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.doctorPhotoUrl,
    required this.messages,
    required this.isMine,
    required this.scrollController,
  });

  final String? doctorPhotoUrl;
  final List<ConsultationMessageEntity> messages;
  final bool Function(ConsultationMessageEntity message) isMine;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const _ChatStateMessage(
        title: 'Belum ada pesan',
        description:
            'Mulai percakapan dengan menjelaskan keluhan Anda ke dokter.',
      );
    }

    return ListView.separated(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final mine = isMine(message);

        return Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!mine) ...[
                _DoctorAvatar(photoUrl: doctorPhotoUrl),
                const SizedBox(width: 8),
              ],
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: mine
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!mine && message.senderName.trim().isNotEmpty) ...[
                      Text(
                        message.senderName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      message.message,
                      style: TextStyle(color: mine ? Colors.white : null),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolvePhotoUrl(photoUrl);

    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundImage: resolvedUrl != null ? NetworkImage(resolvedUrl) : null,
      child: resolvedUrl == null
          ? const Icon(Icons.person_rounded, size: 14, color: AppColors.primary)
          : null,
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

class _PaymentInfoRow extends StatelessWidget {
  const _PaymentInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.lightMutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller});

  final DoctorChatController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                enabled: !controller.isSending.value,
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan untuk dokter',
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 10),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isSending.value
                    ? null
                    : controller.sendMessage,
                child: controller.isSending.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatStateMessage extends StatelessWidget {
  const _ChatStateMessage({
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

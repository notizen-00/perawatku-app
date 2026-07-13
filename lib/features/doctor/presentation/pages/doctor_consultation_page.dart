import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../consultation/domain/entities/consultation_entity.dart';
import '../controllers/doctor_chat_controller.dart';

class DoctorConsultationPage extends GetView<DoctorChatController> {
  const DoctorConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konsultasi Dokter')),
      body: Obx(() {
        if (controller.isInitializing.value &&
            controller.consultation.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.consultation.value == null) {
          return _ConsultationStateMessage(
            title: 'Konsultasi belum siap',
            description: controller.errorMessage.value!,
            actionLabel: 'Coba lagi',
            onTap: controller.initializeConsultation,
          );
        }

        final consultation = controller.consultation.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DoctorSummaryCard(controller: controller),
            const SizedBox(height: 16),
            _ConsultationStatusCard(
              consultation: consultation,
              controller: controller,
            ),
            const SizedBox(height: 16),
            _PaymentInfoCard(controller: controller),
            const SizedBox(height: 16),
            _ConsultationNoteCard(controller: controller),
            const SizedBox(height: 16),
            Obx(
              () => ElevatedButton.icon(
                onPressed:
                    controller.isPreparingChat.value ||
                        controller.isPaying.value
                    ? null
                    : consultation?.isPaid == true
                    ? controller.openChatPage
                    : controller.payConsultation,
                icon:
                    controller.isPreparingChat.value ||
                        controller.isPaying.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        consultation?.isPaid == true
                            ? Icons.chat_bubble_rounded
                            : Icons.account_balance_wallet_rounded,
                      ),
                label: Text(
                  consultation?.isPaid == true
                      ? 'Buka obrolan konsultasi'
                      : consultation == null
                      ? 'Buat dan bayar konsultasi'
                      : controller.isPaymentPending
                      ? 'Bayar ulang konsultasi'
                      : 'Bayar konsultasi',
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Obx(() {
            final consultation = controller.consultation.value;
            final isPaid = consultation?.isPaid ?? false;
            final isReady = !controller.isInitializing.value;

            if (isPaid) {
              return FilledButton.icon(
                onPressed: controller.isPreparingChat.value
                    ? null
                    : controller.openChatPage,
                icon: const Icon(Icons.forum_rounded),
                label: const Text('Lanjut ke obrolan'),
              );
            }

            return ElevatedButton.icon(
              onPressed: !isReady || controller.isPaying.value
                  ? null
                  : controller.payConsultation,
              icon: controller.isPaying.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.account_balance_wallet_rounded),
              label: Text(
                !isReady
                    ? 'Menyiapkan konsultasi...'
                    : controller.isPaying.value
                    ? 'Membuka pembayaran...'
                    : consultation == null
                    ? 'Buat dan bayar konsultasi'
                    : controller.isPaymentPending
                    ? 'Bayar ulang konsultasi'
                    : 'Bayar konsultasi',
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DoctorSummaryCard extends StatelessWidget {
  const _DoctorSummaryCard({required this.controller});

  final DoctorChatController controller;

  @override
  Widget build(BuildContext context) {
    final photoUrl = _resolvePhotoUrl(controller.doctorPhotoUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
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
                  controller.doctorName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.specializationLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    controller.consultationFeeLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
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

class _ConsultationStatusCard extends StatelessWidget {
  const _ConsultationStatusCard({
    required this.consultation,
    required this.controller,
  });

  final ConsultationEntity? consultation;
  final DoctorChatController controller;

  @override
  Widget build(BuildContext context) {
    final isPaid = consultation?.isPaid ?? false;
    final statusLabel = isPaid
        ? 'Pembayaran berhasil dan obrolan siap digunakan'
        : consultation == null
        ? 'Isi catatan gejala lalu lanjutkan ke pembayaran'
        : 'Menunggu pembayaran';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status konsultasi',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(statusLabel),
          if (!controller.isMidtransReady) ...[
            const SizedBox(height: 8),
            Text(
              'Pembayaran online belum tersedia saat ini.',
              style: TextStyle(fontSize: 12, color: AppColors.lightMutedText),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConsultationNoteCard extends StatelessWidget {
  const _ConsultationNoteCard({required this.controller});

  final DoctorChatController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan konsultasi',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.consultationNoteController,
            enabled: controller.consultation.value == null,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
                  'Tulis keluhan, gejala, atau pertanyaan yang ingin Anda sampaikan ke dokter.',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.consultation.value == null
                ? 'Catatan ini akan disimpan sebagai keluhan awal saat konsultasi dibuat.'
                : 'Catatan keluhan awal sudah tersimpan di konsultasi ini.',
            style: TextStyle(fontSize: 12, color: AppColors.lightMutedText),
          ),
        ],
      ),
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  const _PaymentInfoCard({required this.controller});

  final DoctorChatController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Info pembayaran',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _PaymentInfoRow(
            label: 'Status konsultasi',
            value: controller.consultationStatusLabel,
          ),
          const SizedBox(height: 10),
          _PaymentInfoRow(
            label: 'Status pembayaran',
            value: controller.paymentStatusLabel,
          ),
          if (controller.consultation.value?.complaint?.trim().isNotEmpty ==
                  true ||
              controller.consultation.value?.notes?.trim().isNotEmpty ==
                  true) ...[
            const SizedBox(height: 10),
            _PaymentInfoRow(
              label: 'Keluhan awal',
              value:
                  controller.consultation.value?.complaint?.trim().isNotEmpty ==
                      true
                  ? controller.consultation.value!.complaint!.trim()
                  : controller.consultation.value?.notes?.trim() ?? '-',
            ),
          ],
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
          _PaymentInfoRow(label: 'Dibayar pada', value: controller.paidAtLabel),
          const SizedBox(height: 10),
          _PaymentInfoRow(
            label: 'Catatan',
            value: controller.paymentNotesLabel,
          ),
        ],
      ),
    );
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

class _ConsultationStateMessage extends StatelessWidget {
  const _ConsultationStateMessage({
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

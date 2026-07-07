import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/helpers/app_snackbar.dart';
import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/midtrans_service.dart';
import '../../../../core/services/reverb_websocket_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../consultation/data/models/consultation_message_model.dart';
import '../../../activity/presentation/controllers/activity_controller.dart';
import '../../../consultation/domain/entities/consultation_entity.dart';
import '../../../consultation/domain/entities/consultation_message_entity.dart';
import '../../../home/controller/home_controller.dart';
import '../../../consultation/domain/usecases/create_consultation_use_case.dart';
import '../../../consultation/domain/usecases/get_consultation_use_case.dart';
import '../../../consultation/domain/usecases/pay_consultation_use_case.dart';
import '../../../consultation/domain/usecases/send_consultation_message_use_case.dart';
import '../../domain/entities/doctor_entity.dart';
import '../models/doctor_chat_arguments.dart';

class DoctorChatController extends GetxController {
  DoctorChatController({
    required CreateConsultationUseCase createConsultationUseCase,
    required GetConsultationUseCase getConsultationUseCase,
    required PayConsultationUseCase payConsultationUseCase,
    required SendConsultationMessageUseCase sendConsultationMessageUseCase,
    required MidtransService midtransService,
    required StorageService storageService,
    required ReverbWebSocketService reverbWebSocketService,
  }) : _createConsultationUseCase = createConsultationUseCase,
       _getConsultationUseCase = getConsultationUseCase,
       _payConsultationUseCase = payConsultationUseCase,
       _sendConsultationMessageUseCase = sendConsultationMessageUseCase,
       _midtransService = midtransService,
       _storageService = storageService,
       _reverbWebSocketService = reverbWebSocketService;

  final CreateConsultationUseCase _createConsultationUseCase;
  final GetConsultationUseCase _getConsultationUseCase;
  final PayConsultationUseCase _payConsultationUseCase;
  final SendConsultationMessageUseCase _sendConsultationMessageUseCase;
  final MidtransService _midtransService;
  final StorageService _storageService;
  final ReverbWebSocketService _reverbWebSocketService;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController consultationNoteController =
      TextEditingController();
  final ScrollController messageScrollController = ScrollController();

  final Rxn<DoctorEntity> doctor = Rxn<DoctorEntity>();
  final Rxn<ConsultationEntity> consultation = Rxn<ConsultationEntity>();
  final RxList<ConsultationMessageEntity> messages =
      <ConsultationMessageEntity>[].obs;
  final RxBool isInitializing = false.obs;
  final RxBool isPaying = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isPreparingChat = false.obs;
  final RxnString errorMessage = RxnString();
  DoctorChatArguments? _arguments;
  bool _isSyncingPayment = false;
  bool _isSyncingMessages = false;
  Timer? _messageSyncTimer;
  String? _subscribedConsultationChannel;

  int? get currentUserId => _storageService.userId;

  bool get isMidtransReady =>
      _midtransService.isSupportedPlatform && _midtransService.isConfigured;

  String get consultationFeeLabel {
    final amount = consultation.value?.totalAmount;
    if (amount != null && amount > 0) {
      return CurrencyFormatter.formatRupiahFromString(amount.toString());
    }

    final rawFee = doctor.value?.profile?.consultationFee;
    if (rawFee != null && rawFee.trim().isNotEmpty) {
      return CurrencyFormatter.formatRupiahFromString(rawFee);
    }

    return 'Biaya belum tersedia';
  }

  String get doctorName =>
      doctor.value?.name ?? _arguments?.doctorName ?? 'Konsultasi Chat';

  String get consultationTitle =>
      consultation.value?.consultationCode?.trim().isNotEmpty == true
      ? consultation.value!.consultationCode!
      : 'Konsultasi Chat';

  String get specializationLabel =>
      doctor.value?.profile?.specialization ??
      _arguments?.specialization ??
      'Konsultasi dokter via chat';

  String get consultationStatusLabel =>
      _formatStatusLabel(consultation.value?.status, fallback: 'Menunggu');

  String get paymentStatusLabel => _formatStatusLabel(
    consultation.value?.paymentStatus,
    fallback: 'Belum dibayar',
  );

  bool get isPaymentPending {
    final paymentStatus = consultation.value?.paymentStatus.toLowerCase() ?? '';
    final consultationStatus = consultation.value?.status.toLowerCase() ?? '';

    return paymentStatus == 'pending' ||
        consultationStatus == 'pending' ||
        consultationStatus == 'scheduled' ||
        consultationStatus == 'processing';
  }

  String get paymentReferenceLabel =>
      consultation.value?.orderId?.trim().isNotEmpty == true
      ? consultation.value!.orderId!
      : 'Belum tersedia';

  String get paymentMethodLabel => _formatStatusLabel(
    consultation.value?.paymentMethod,
    fallback: 'Belum tersedia',
  );

  String get paymentNotesLabel {
    final notes = consultation.value?.paymentNotes?.trim();
    if (notes == null || notes.isEmpty) {
      return 'Tidak ada catatan pembayaran.';
    }

    return notes;
  }

  String get paidAtLabel {
    final value = consultation.value?.paidAt?.trim();
    if (value == null || value.isEmpty) {
      return 'Belum dibayar';
    }

    final dateTime = DateTime.tryParse(value);
    if (dateTime == null) {
      return value;
    }

    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _monthName(local.month);
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  String? get doctorPhotoUrl =>
      doctor.value?.profile?.photoUrl ?? _arguments?.doctorPhotoUrl;

  int? get partnerUserId =>
      doctor.value?.profile?.userId ??
      doctor.value?.id ??
      _arguments?.partnerUserId;

  @override
  void onInit() {
    super.onInit();
    _arguments = _parseArguments(Get.arguments);
    doctor.value = _arguments?.doctor;
    _midtransService.setTransactionFinishedCallback(_handleTransactionFinished);
    initializeConsultation();
  }

  Future<void> initializeConsultation() async {
    final existingConsultationId = _arguments?.consultationId;
    final selectedPartnerUserId = partnerUserId;

    if (existingConsultationId == null && selectedPartnerUserId == null) {
      errorMessage.value = 'Data dokter tidak ditemukan.';
      return;
    }

    isInitializing.value = true;
    errorMessage.value = null;

    try {
      if (existingConsultationId != null) {
        final existing = await _getConsultationUseCase(existingConsultationId);
        _applyConsultation(existing);
      } else {
        consultation.value = null;
      }
    } on AppException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Gagal menyiapkan konsultasi chat.';
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> refreshConsultation() async {
    final consultationId = consultation.value?.id;
    if (consultationId == null || consultationId == 0) {
      return;
    }

    isRefreshing.value = true;

    try {
      final result = await _getConsultationUseCase(consultationId);
      _applyConsultation(result);
    } on AppException catch (error) {
      AppSnackbar.error('Gagal memuat', error.message);
    } catch (_) {
      AppSnackbar.error('Gagal memuat', 'Konsultasi belum bisa diperbarui.');
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> payConsultation() async {
    if (!_midtransService.isSupportedPlatform) {
      AppSnackbar.info(
        'Midtrans tidak tersedia',
        'Pembayaran Midtrans hanya berjalan di Android atau iOS.',
      );
      return;
    }

    if (!_midtransService.isConfigured) {
      AppSnackbar.error(
        'Midtrans belum aktif',
        'Isi MIDTRANS_CLIENT_KEY terlebih dulu agar pembayaran bisa dipakai.',
      );
      return;
    }

    isPaying.value = true;

    try {
      final currentConsultation = await _ensureConsultationCreated();
      final payment = await _payConsultationUseCase(currentConsultation.id);

      await _midtransService.startPayment(snapToken: payment.snapToken);

      if (!(consultation.value?.isPaid ?? false)) {
        await _syncConsultationAfterPayment(showFailureMessage: false);
      }
    } on AppException catch (error) {
      AppSnackbar.error('Pembayaran gagal', error.message);
    } on FormatException catch (error) {
      AppSnackbar.error('Pembayaran gagal', error.message);
    } catch (_) {
      AppSnackbar.error(
        'Pembayaran gagal',
        'Tidak bisa membuka halaman pembayaran Midtrans.',
      );
    } finally {
      isPaying.value = false;
    }
  }

  Future<void> sendMessage() async {
    final currentConsultation = consultation.value;
    final message = messageController.text.trim();

    if (currentConsultation == null) {
      AppSnackbar.error('Pesan gagal', 'Konsultasi belum siap.');
      return;
    }

    if (!currentConsultation.isPaid) {
      AppSnackbar.info(
        'Pembayaran dibutuhkan',
        'Selesaikan pembayaran dulu sebelum chat dimulai.',
      );
      return;
    }

    if (message.isEmpty) {
      return;
    }

    isSending.value = true;

    try {
      final sentMessage = await _sendConsultationMessageUseCase(
        consultationId: currentConsultation.id,
        message: message,
        messageType: 'text',
      );

      _appendMessageIfNew(sentMessage);
      messageController.clear();
      _scheduleMessageSync();
    } on AppException catch (error) {
      AppSnackbar.error('Pesan gagal', error.message);
    } catch (_) {
      AppSnackbar.error('Pesan gagal', 'Tidak bisa mengirim pesan saat ini.');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> openChatPage() async {
    final currentConsultation = consultation.value;
    if (currentConsultation == null) {
      AppSnackbar.info(
        'Pembayaran dibutuhkan',
        'Buat dan bayar konsultasi dulu sebelum membuka chat.',
      );
      return;
    }

    isPreparingChat.value = true;

    try {
      if (!currentConsultation.isPaid) {
        await _syncConsultationAfterPayment(showFailureMessage: false);
      }

      final latestConsultation = consultation.value;
      if (latestConsultation == null || !latestConsultation.isPaid) {
        AppSnackbar.info(
          'Pembayaran dibutuhkan',
          'Selesaikan pembayaran konsultasi dulu sebelum membuka chat.',
        );
        return;
      }

      if (Get.currentRoute != AppRoutes.doctorChat) {
        await Get.toNamed(
          AppRoutes.doctorChat,
          arguments: _buildChatArguments(consultationId: latestConsultation.id),
        );
      }
    } on AppException catch (error) {
      AppSnackbar.error('Chat belum siap', error.message);
    } catch (_) {
      AppSnackbar.error(
        'Chat belum siap',
        'Status konsultasi belum bisa disiapkan saat ini.',
      );
    } finally {
      isPreparingChat.value = false;
    }
  }

  bool isMine(ConsultationMessageEntity message) {
    final currentId = currentUserId;
    if (currentId != null && message.senderId != null) {
      return currentId == message.senderId;
    }

    return message.senderRole.toLowerCase() == 'patient';
  }

  void _applyConsultation(ConsultationEntity value) {
    consultation.value = value;
    _applyExistingConsultationNotes(value);
    messages.assignAll(value.messages);
    _scrollToLatestMessage();
    _subscribeToConsultationChannelIfNeeded(value);
  }

  void _applyExistingConsultationNotes(ConsultationEntity value) {
    if (consultationNoteController.text.trim().isNotEmpty) {
      return;
    }

    final note = value.complaint?.trim().isNotEmpty == true
        ? value.complaint!.trim()
        : value.notes?.trim();

    if (note != null && note.isNotEmpty) {
      consultationNoteController.text = note;
    }
  }

  Future<ConsultationEntity> _ensureConsultationCreated() async {
    final currentConsultation = consultation.value;
    if (currentConsultation != null) {
      return currentConsultation;
    }

    final selectedPartnerUserId = partnerUserId;
    if (selectedPartnerUserId == null) {
      throw AppException('Data dokter tidak ditemukan.');
    }

    final symptomNote = consultationNoteController.text.trim();
    final created = await _createConsultationUseCase(
      partnerUserId: selectedPartnerUserId,
      serviceType: 'chat',
      paymentMethod: 'midtrans',
      complaint: symptomNote.isEmpty ? null : symptomNote,
      notes: symptomNote.isEmpty ? null : symptomNote,
    );
    _applyConsultation(created);

    return created;
  }

  Future<void> _subscribeToConsultationChannelIfNeeded(
    ConsultationEntity value,
  ) async {
    if (!value.isPaid || value.id == 0) {
      return;
    }

    final channelName = 'private-consultation.${value.id}';
    if (_subscribedConsultationChannel == channelName) {
      return;
    }

    final previousChannel = _subscribedConsultationChannel;
    _subscribedConsultationChannel = channelName;

    if (previousChannel != null) {
      await _reverbWebSocketService.unsubscribe(
        channelName: previousChannel,
        onEvent: _handleConsultationSocketEvent,
      );
    }

    try {
      await _reverbWebSocketService.subscribePrivateChannel(
        channelName: channelName,
        onEvent: _handleConsultationSocketEvent,
      );
    } catch (_) {
      _subscribedConsultationChannel = null;
    }
  }

  void _handleConsultationSocketEvent(
    Map<String, dynamic> payload,
    String eventName,
  ) {
    if (eventName != 'chat.message.created') {
      return;
    }

    final message = ConsultationMessageModel.fromJson(
      _extractMessagePayload(payload),
    );
    if (message.consultationId != consultation.value?.id) {
      return;
    }

    final added = _appendMessageIfNew(message);
    if (added && !isMine(message)) {
      _showIncomingMessageNotification(message);
    }
    _scheduleMessageSync();
  }

  Map<String, dynamic> _extractMessagePayload(Map<String, dynamic> payload) {
    final nestedMessage = payload['message'];
    if (nestedMessage is Map<String, dynamic>) {
      return nestedMessage;
    }

    final nestedData = payload['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }

    return payload;
  }

  bool _appendMessageIfNew(ConsultationMessageEntity message) {
    final alreadyExists = messages.any((item) {
      if (message.id != 0 && item.id == message.id) {
        return true;
      }

      return item.senderId == message.senderId &&
          item.message == message.message &&
          item.createdAt == message.createdAt;
    });

    if (alreadyExists) {
      return false;
    }

    messages.add(message);
    _scrollToLatestMessage();
    return true;
  }

  void _scrollToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!messageScrollController.hasClients) {
        return;
      }

      messageScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _showIncomingMessageNotification(ConsultationMessageEntity message) {
    final senderName = message.senderName.trim().isNotEmpty
        ? message.senderName
        : doctorName;
    final preview = message.message.trim().isNotEmpty
        ? message.message.trim()
        : 'Mengirim pesan baru.';

    AppSnackbar.notification('Pesan baru dari $senderName', preview);
  }

  void _scheduleMessageSync() {
    _messageSyncTimer?.cancel();
    _messageSyncTimer = Timer(
      const Duration(milliseconds: 450),
      _syncLatestConsultationMessages,
    );
  }

  Future<void> _syncLatestConsultationMessages() async {
    if (_isSyncingMessages) {
      return;
    }

    final consultationId = consultation.value?.id;
    if (consultationId == null || consultationId == 0) {
      return;
    }

    _isSyncingMessages = true;

    try {
      final latest = await _getConsultationUseCase(consultationId);
      _applyConsultation(latest);
    } catch (_) {
      // Realtime event/HTTP response already added the newest known message.
    } finally {
      _isSyncingMessages = false;
    }
  }

  Future<void> _handleTransactionFinished(TransactionResult result) async {
    final status = result.status.toLowerCase();

    if (status == 'settlement' || status == 'capture') {
      AppSnackbar.success(
        'Pembayaran berhasil',
        'Konsultasi sudah aktif. Anda bisa mulai chat dengan dokter.',
      );
    } else if (status == 'pending') {
      AppSnackbar.info(
        'Pembayaran tertunda',
        'Transaksi tercatat. Status konsultasi akan diperbarui setelah pembayaran masuk.',
      );
      await _syncConsultationAfterPayment(
        maxAttempts: 1,
        showFailureMessage: false,
      );
      _redirectToActivityTab();
      return;
    } else if (status == 'cancel' || status == 'deny' || status == 'expire') {
      AppSnackbar.error(
        'Pembayaran belum selesai',
        result.message ?? 'Silakan coba lagi dengan metode pembayaran lain.',
      );
    } else {
      AppSnackbar.info(
        'Status pembayaran',
        result.message ?? 'Transaksi diproses oleh Midtrans.',
      );
    }

    await _syncConsultationAfterPayment();
  }

  Future<void> _syncConsultationAfterPayment({
    int maxAttempts = 6,
    bool showFailureMessage = true,
  }) async {
    if (_isSyncingPayment) {
      return;
    }

    final consultationId = consultation.value?.id;
    if (consultationId == null || consultationId == 0) {
      return;
    }

    _isSyncingPayment = true;
    isRefreshing.value = true;

    try {
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final latest = await _getConsultationUseCase(consultationId);
        _applyConsultation(latest);

        if (latest.isPaid) {
          if (Get.currentRoute == AppRoutes.doctorConsultation) {
            await Get.toNamed(
              AppRoutes.doctorChat,
              arguments: _buildChatArguments(consultationId: latest.id),
            );
          } else if (!Get.isSnackbarOpen) {
            AppSnackbar.success(
              'Chat siap dipakai',
              'Pembayaran sudah terverifikasi dan chat dengan dokter sudah terbuka.',
            );
          }
          return;
        }

        await Future.delayed(const Duration(seconds: 2));
      }
    } on AppException catch (error) {
      if (showFailureMessage) {
        AppSnackbar.error('Sinkronisasi gagal', error.message);
      }
    } catch (_) {
      if (showFailureMessage) {
        AppSnackbar.error(
          'Sinkronisasi gagal',
          'Status pembayaran belum bisa diperbarui otomatis.',
        );
      }
    } finally {
      _isSyncingPayment = false;
      isRefreshing.value = false;
    }
  }

  void _redirectToActivityTab() {
    if (Get.isRegistered<ActivityController>()) {
      Get.find<ActivityController>().loadActivities();
    }

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().selectBottomNav(1);
      if (Get.currentRoute != AppRoutes.home) {
        Get.offAllNamed(AppRoutes.home);
      }
      return;
    }

    Get.offAllNamed(AppRoutes.home);
  }

  DoctorChatArguments _buildChatArguments({required int consultationId}) {
    return DoctorChatArguments(
      doctor: doctor.value,
      consultationId: consultationId,
      doctorName: doctorName,
      specialization: specializationLabel,
      partnerUserId: partnerUserId,
      doctorPhotoUrl: doctorPhotoUrl,
    );
  }

  DoctorChatArguments? _parseArguments(dynamic rawArguments) {
    if (rawArguments is DoctorEntity) {
      return DoctorChatArguments(doctor: rawArguments);
    }

    if (rawArguments is DoctorChatArguments) {
      return rawArguments;
    }

    return null;
  }

  String _formatStatusLabel(String? rawStatus, {required String fallback}) {
    final value = rawStatus?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }

    final normalized = value.replaceAll('_', ' ').replaceAll('-', ' ');
    return normalized
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _monthName(int month) {
    const monthNames = <String>[
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

    if (month < 1 || month >= monthNames.length) {
      return '-';
    }

    return monthNames[month];
  }

  @override
  void onClose() {
    _messageSyncTimer?.cancel();
    final channelName = _subscribedConsultationChannel;
    if (channelName != null) {
      _reverbWebSocketService.unsubscribe(
        channelName: channelName,
        onEvent: _handleConsultationSocketEvent,
      );
    }
    messageScrollController.dispose();
    messageController.dispose();
    consultationNoteController.dispose();
    _midtransService.removeTransactionFinishedCallback();
    super.onClose();
  }
}

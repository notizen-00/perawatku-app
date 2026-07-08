import 'package:get/get.dart';

import '../../../../core/helpers/app_snackbar.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/reverb_websocket_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../doctor/presentation/models/doctor_chat_arguments.dart';
import '../../../home/controller/home_controller.dart';
import '../../data/models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  NotificationController({
    required NotificationRepository notificationRepository,
    required ReverbWebSocketService reverbWebSocketService,
    required StorageService storageService,
  }) : _notificationRepository = notificationRepository,
       _reverbWebSocketService = reverbWebSocketService,
       _storageService = storageService;

  final NotificationRepository _notificationRepository;
  final ReverbWebSocketService _reverbWebSocketService;
  final StorageService _storageService;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxnString errorMessage = RxnString();
  final RxInt unreadCount = 0.obs;
  final RxList<NotificationEntity> notifications = <NotificationEntity>[].obs;
  final RxString selectedCategory = NotificationCategoryOption.all.key.obs;

  String? _subscribedChannel;

  List<NotificationCategoryOption> get categoryOptions => const [
    NotificationCategoryOption(
      key: 'all',
      label: 'Semua',
      iconName: 'notifications',
    ),
    NotificationCategoryOption(
      key: 'unread',
      label: 'Belum dibaca',
      iconName: 'unread',
    ),
    NotificationCategoryOption(key: 'chat', label: 'Chat', iconName: 'chat'),
    NotificationCategoryOption(
      key: 'system',
      label: 'Sistem',
      iconName: 'system',
    ),
    NotificationCategoryOption(
      key: 'consultation',
      label: 'Konsultasi',
      iconName: 'consultation',
    ),
    NotificationCategoryOption(
      key: 'service_booking',
      label: 'Layanan',
      iconName: 'service',
    ),
  ];

  List<NotificationEntity> get filteredNotifications {
    final category = selectedCategory.value;
    if (category == NotificationCategoryOption.all.key) {
      return notifications.toList();
    }

    return notifications.where((notification) {
      if (category == 'unread') {
        return notification.isUnread;
      }

      return notification.categoryKey == category;
    }).toList();
  }

  void selectCategory(String key) {
    selectedCategory.value = key;
  }

  int categoryCount(String key) {
    if (key == NotificationCategoryOption.all.key) {
      return notifications.length;
    }

    if (key == 'unread') {
      return notifications
          .where((notification) => notification.isUnread)
          .length;
    }

    return notifications
        .where((notification) => notification.categoryKey == key)
        .length;
  }

  @override
  void onInit() {
    super.onInit();
    refreshNotifications(showLoading: true);
    _subscribeToUserNotificationChannel();
  }

  Future<void> refreshNotifications({bool showLoading = false}) async {
    if (showLoading) {
      isLoading.value = true;
    } else {
      isRefreshing.value = true;
    }
    errorMessage.value = null;

    try {
      final results = await _notificationRepository.getNotifications();
      notifications.assignAll(results);
      unreadCount.value = await _notificationRepository.getUnreadCount();
    } catch (_) {
      errorMessage.value = 'Notifikasi belum bisa dimuat.';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    if (notifications.isEmpty) {
      return;
    }

    try {
      await _notificationRepository.markAllAsRead();
      unreadCount.value = 0;
      await refreshNotifications();
    } catch (_) {
      AppSnackbar.error(
        'Gagal memperbarui',
        'Notifikasi belum bisa ditandai terbaca.',
      );
    }
  }

  Future<void> openNotification(NotificationEntity notification) async {
    if (notification.isUnread) {
      try {
        await _notificationRepository.markAsRead(notification.id);
        unreadCount.value = unreadCount.value > 0 ? unreadCount.value - 1 : 0;
        await refreshNotifications();
      } catch (_) {
        AppSnackbar.error(
          'Gagal memperbarui',
          'Notifikasi belum bisa ditandai terbaca.',
        );
      }
    }

    _openReference(notification);
  }

  void _openReference(NotificationEntity notification) {
    final consultationId = _readInt(
      notification.data['consultation_id'] ?? notification.referenceId,
    );

    if (notification.referenceType == 'consultation' ||
        notification.type.startsWith('consultation.')) {
      if (consultationId != null) {
        final route = notification.type == 'consultation.message_created'
            ? AppRoutes.doctorChat
            : AppRoutes.doctorConsultation;
        Get.toNamed(
          route,
          arguments: DoctorChatArguments(consultationId: consultationId),
        );
        return;
      }
    }

    if (notification.referenceType == 'service_booking' ||
        notification.type.startsWith('service_booking.')) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().selectBottomNav(1);
        Get.offNamedUntil(AppRoutes.home, (route) => route.isFirst);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
      return;
    }
  }

  Future<void> _subscribeToUserNotificationChannel() async {
    final userId = _storageService.userId;
    if (userId == null) {
      return;
    }

    final channelName = 'private-user.$userId.notifications';
    if (_subscribedChannel == channelName) {
      return;
    }

    _subscribedChannel = channelName;

    try {
      await _reverbWebSocketService.subscribePrivateChannel(
        channelName: channelName,
        onEvent: _handleNotificationSocketEvent,
      );
    } catch (_) {
      _subscribedChannel = null;
    }
  }

  void _handleNotificationSocketEvent(
    Map<String, dynamic> payload,
    String eventName,
  ) {
    if (eventName != 'notification.created') {
      return;
    }

    final notification = NotificationModel.fromJson(
      _extractNotificationPayload(payload),
    );
    final alreadyExists = notifications.any(
      (item) => item.id == notification.id,
    );
    if (!alreadyExists) {
      notifications.insert(0, notification);
      if (notification.isUnread) {
        unreadCount.value = unreadCount.value + 1;
      }
    }

    AppSnackbar.notification(notification.title, notification.body);
  }

  Map<String, dynamic> _extractNotificationPayload(
    Map<String, dynamic> payload,
  ) {
    final nestedNotification = payload['notification'];
    if (nestedNotification is Map<String, dynamic>) {
      return nestedNotification;
    }

    final nestedData = payload['data'];
    if (nestedData is Map<String, dynamic> &&
        (nestedData.containsKey('title') || nestedData.containsKey('body'))) {
      return nestedData;
    }

    return payload;
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  @override
  void onClose() {
    final channelName = _subscribedChannel;
    if (channelName != null) {
      _reverbWebSocketService.unsubscribe(
        channelName: channelName,
        onEvent: _handleNotificationSocketEvent,
      );
    }
    super.onClose();
  }
}

class NotificationCategoryOption {
  const NotificationCategoryOption({
    required this.key,
    required this.label,
    required this.iconName,
  });

  static const all = NotificationCategoryOption(
    key: 'all',
    label: 'Semua',
    iconName: 'notifications',
  );

  final String key;
  final String label;
  final String iconName;
}

import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications({
    String? status,
    String? type,
    int perPage = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(int notificationId);

  Future<void> markAllAsRead();
}

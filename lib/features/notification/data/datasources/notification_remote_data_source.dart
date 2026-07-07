import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    String? status,
    String? type,
    int perPage = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(int notificationId);

  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<NotificationModel>> getNotifications({
    String? status,
    String? type,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get(
      AppEndpoints.sharedNotifications,
      queryParameters: {
        'per_page': perPage,
        if (status != null && status.trim().isNotEmpty) 'status': status,
        if (type != null && type.trim().isNotEmpty) 'type': type,
      },
    );

    return _extractItems(response).map(NotificationModel.fromJson).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(
      AppEndpoints.sharedNotificationUnreadCount,
    );
    final directData = response['data'];

    return _parseInt(
          response['unread_count'] ??
              response['count'] ??
              (directData is Map<String, dynamic>
                  ? directData['unread_count'] ?? directData['count']
                  : directData),
        ) ??
        0;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await _apiClient.patch(
      '${AppEndpoints.sharedNotifications}/$notificationId/read',
    );
  }

  @override
  Future<void> markAllAsRead() async {
    await _apiClient.patch(AppEndpoints.sharedNotificationReadAll);
  }

  List<Map<String, dynamic>> _extractItems(Map<String, dynamic> response) {
    final directData = response['data'];
    if (directData is List) {
      return directData.whereType<Map<String, dynamic>>().toList();
    }

    if (directData is Map<String, dynamic>) {
      final nestedData = directData['data'];
      if (nestedData is List) {
        return nestedData.whereType<Map<String, dynamic>>().toList();
      }

      final notifications = directData['notifications'];
      if (notifications is List) {
        return notifications.whereType<Map<String, dynamic>>().toList();
      }
    }

    final notifications = response['notifications'];
    if (notifications is List) {
      return notifications.whereType<Map<String, dynamic>>().toList();
    }

    return <Map<String, dynamic>>[];
  }

  int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }
}

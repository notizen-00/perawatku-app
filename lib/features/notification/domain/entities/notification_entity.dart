class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.actionUrl,
    required this.referenceType,
    required this.referenceId,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });

  final int id;
  final int? userId;
  final String type;
  final String title;
  final String body;
  final String? actionUrl;
  final String? referenceType;
  final int? referenceId;
  final Map<String, dynamic> data;
  final String? readAt;
  final String createdAt;

  bool get isUnread => readAt == null || readAt!.trim().isEmpty;

  String get categoryKey {
    final normalizedType = type.toLowerCase().trim();
    final normalizedReference = referenceType?.toLowerCase().trim() ?? '';
    final messageType = data['message_type']?.toString().toLowerCase().trim();
    final senderRole =
        data['sender_role']?.toString().toLowerCase().trim() ??
        data['sender_type']?.toString().toLowerCase().trim() ??
        data['role']?.toString().toLowerCase().trim();

    if (messageType == 'system' ||
        senderRole == 'system' ||
        normalizedType.contains('system')) {
      return 'system';
    }

    if (normalizedType.contains('message') ||
        normalizedType.contains('chat') ||
        normalizedReference == 'chat') {
      return 'chat';
    }

    if (normalizedType.startsWith('consultation.') ||
        normalizedReference == 'consultation') {
      return 'consultation';
    }

    if (normalizedType.startsWith('service_booking.') ||
        normalizedReference == 'service_booking') {
      return 'service_booking';
    }

    if (normalizedType.contains('payment') ||
        normalizedReference == 'payment') {
      return 'payment';
    }

    return 'system';
  }
}

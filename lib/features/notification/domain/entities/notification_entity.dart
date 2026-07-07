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
}

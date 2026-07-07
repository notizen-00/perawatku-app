import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.body,
    required super.actionUrl,
    required super.referenceType,
    required super.referenceId,
    required super.data,
    required super.readAt,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return NotificationModel(
      id: _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']),
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notifikasi',
      body: json['body']?.toString() ?? '',
      actionUrl: _readString(json['action_url']),
      referenceType: _readString(json['reference_type']),
      referenceId: _parseInt(json['reference_id']),
      data: rawData is Map<String, dynamic>
          ? rawData
          : rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{},
      readAt: _readString(json['read_at']),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static String? _readString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

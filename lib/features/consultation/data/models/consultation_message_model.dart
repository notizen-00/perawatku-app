import '../../domain/entities/consultation_message_entity.dart';

class ConsultationMessageModel extends ConsultationMessageEntity {
  const ConsultationMessageModel({
    required super.id,
    required super.consultationId,
    required super.senderId,
    required super.senderName,
    required super.senderRole,
    required super.message,
    required super.createdAt,
  });

  factory ConsultationMessageModel.fromJson(Map<String, dynamic> json) {
    final sender =
        json['sender'] is Map<String, dynamic>
            ? json['sender'] as Map<String, dynamic>
            : json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : <String, dynamic>{};

    return ConsultationMessageModel(
      id: _parseInt(json['id']) ?? 0,
      consultationId:
          _parseInt(json['consultation_id'] ?? json['patient_consultation_id']) ??
          0,
      senderId: _parseInt(
        json['sender_id'] ?? json['user_id'] ?? sender['id'],
      ),
      senderName:
          json['sender_name']?.toString() ??
          sender['name']?.toString() ??
          json['name']?.toString() ??
          '',
      senderRole:
          json['sender_role']?.toString() ??
          sender['role']?.toString() ??
          '',
      message:
          json['message']?.toString() ??
          json['content']?.toString() ??
          json['body']?.toString() ??
          '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '');
  }
}

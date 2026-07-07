import '../../domain/entities/consultation_entity.dart';
import 'consultation_message_model.dart';

class ConsultationModel extends ConsultationEntity {
  const ConsultationModel({
    required super.id,
    required super.consultationCode,
    required super.doctorId,
    required super.patientId,
    required super.status,
    required super.paymentStatus,
    required super.snapToken,
    required super.orderId,
    required super.totalAmount,
    required super.createdAt,
    required super.updatedAt,
    required super.paymentMethod,
    required super.paymentNotes,
    required super.paidAt,
    required super.complaint,
    required super.notes,
    required super.messages,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'] is Map<String, dynamic>
        ? json['payment'] as Map<String, dynamic>
        : <String, dynamic>{};

    return ConsultationModel(
      id: _parseInt(json['id']) ?? 0,
      consultationCode: _readString(
        json['consultation_code'] ?? json['code'] ?? json['reference_code'],
      ),
      doctorId: _parseInt(
        json['doctor_id'] ??
            json['doctor_user_id'] ??
            json['partner_id'] ??
            json['doctor']?['id'],
      ),
      patientId: _parseInt(
        json['patient_id'] ?? json['patient_user_id'] ?? json['patient']?['id'],
      ),
      status: json['status']?.toString() ?? '',
      paymentStatus:
          json['payment_status']?.toString() ??
          json['transaction_status']?.toString() ??
          payment['status']?.toString() ??
          '',
      snapToken: _readString(
        json['snap_token'] ??
            json['token'] ??
            json['payment_token'] ??
            payment['snap_token'],
      ),
      orderId: _readString(
        json['order_id'] ??
            json['midtrans_order_id'] ??
            payment['payment_code'] ??
            payment['order_id'],
      ),
      totalAmount: _parseInt(
        json['consultation_fee'] ??
            json['total_amount'] ??
            json['amount'] ??
            json['gross_amount'] ??
            payment['amount'],
      ),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      paymentMethod: _readString(payment['payment_method']),
      paymentNotes: _readString(payment['notes']),
      paidAt: _readString(payment['paid_at']),
      complaint: _readString(json['complaint']),
      notes: _readString(json['notes']),
      messages: _extractMessages(json),
    );
  }

  static List<ConsultationMessageModel> _extractMessages(
    Map<String, dynamic> json,
  ) {
    final candidates = [
      json['messages'],
      json['chat_messages'],
      json['consultation_messages'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map<String, dynamic>>()
            .map(ConsultationMessageModel.fromJson)
            .toList();
      }
    }

    return <ConsultationMessageModel>[];
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

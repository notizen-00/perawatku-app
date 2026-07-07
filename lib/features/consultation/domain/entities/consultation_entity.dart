import 'consultation_message_entity.dart';

class ConsultationEntity {
  const ConsultationEntity({
    required this.id,
    required this.consultationCode,
    required this.doctorId,
    required this.patientId,
    required this.status,
    required this.paymentStatus,
    required this.snapToken,
    required this.orderId,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentMethod,
    required this.paymentNotes,
    required this.paidAt,
    required this.complaint,
    required this.notes,
    required this.messages,
  });

  final int id;
  final String? consultationCode;
  final int? doctorId;
  final int? patientId;
  final String status;
  final String paymentStatus;
  final String? snapToken;
  final String? orderId;
  final int? totalAmount;
  final String createdAt;
  final String updatedAt;
  final String? paymentMethod;
  final String? paymentNotes;
  final String? paidAt;
  final String? complaint;
  final String? notes;
  final List<ConsultationMessageEntity> messages;

  bool get isPaid {
    final normalizedStatus = status.toLowerCase();
    final normalizedPaymentStatus = paymentStatus.toLowerCase();

    return normalizedStatus == 'paid' ||
        normalizedStatus == 'active' ||
        normalizedStatus == 'ongoing' ||
        normalizedStatus == 'opened' ||
        normalizedStatus == 'confirmed' ||
        normalizedStatus == 'completed' ||
        normalizedStatus == 'done' ||
        normalizedStatus == 'approved' ||
        normalizedPaymentStatus == 'paid' ||
        normalizedPaymentStatus == 'settlement' ||
        normalizedPaymentStatus == 'capture' ||
        normalizedPaymentStatus == 'success' ||
        normalizedPaymentStatus == 'completed' ||
        normalizedPaymentStatus == 'done' ||
        normalizedPaymentStatus == 'approved';
  }
}

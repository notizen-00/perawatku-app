class ConsultationMessageEntity {
  const ConsultationMessageEntity({
    required this.id,
    required this.consultationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final int consultationId;
  final int? senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final String createdAt;
}

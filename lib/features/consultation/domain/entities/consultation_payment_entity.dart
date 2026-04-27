class ConsultationPaymentEntity {
  const ConsultationPaymentEntity({
    required this.snapToken,
    required this.redirectUrl,
    required this.paymentStatus,
    required this.orderId,
  });

  final String snapToken;
  final String? redirectUrl;
  final String paymentStatus;
  final String? orderId;
}

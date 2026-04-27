import '../entities/consultation_entity.dart';
import '../entities/consultation_message_entity.dart';
import '../entities/consultation_payment_entity.dart';

abstract class ConsultationRepository {
  Future<ConsultationEntity> createConsultation({
    required int partnerUserId,
    required String serviceType,
    required String paymentMethod,
  });

  Future<ConsultationEntity> getConsultation(int consultationId);

  Future<ConsultationPaymentEntity> payConsultation(int consultationId);

  Future<ConsultationMessageEntity> addMessage({
    required int consultationId,
    required String message,
  });
}

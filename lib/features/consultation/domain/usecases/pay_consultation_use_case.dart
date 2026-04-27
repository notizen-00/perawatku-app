import '../entities/consultation_payment_entity.dart';
import '../repositories/consultation_repository.dart';

class PayConsultationUseCase {
  PayConsultationUseCase(this._repository);

  final ConsultationRepository _repository;

  Future<ConsultationPaymentEntity> call(int consultationId) {
    return _repository.payConsultation(consultationId);
  }
}

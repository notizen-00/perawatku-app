import '../entities/consultation_entity.dart';
import '../repositories/consultation_repository.dart';

class CreateConsultationUseCase {
  CreateConsultationUseCase(this._repository);

  final ConsultationRepository _repository;

  Future<ConsultationEntity> call({
    required int partnerUserId,
    required String serviceType,
    required String paymentMethod,
    String? complaint,
    String? notes,
  }) {
    return _repository.createConsultation(
      partnerUserId: partnerUserId,
      serviceType: serviceType,
      paymentMethod: paymentMethod,
      complaint: complaint,
      notes: notes,
    );
  }
}

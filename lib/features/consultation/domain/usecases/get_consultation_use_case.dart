import '../entities/consultation_entity.dart';
import '../repositories/consultation_repository.dart';

class GetConsultationUseCase {
  GetConsultationUseCase(this._repository);

  final ConsultationRepository _repository;

  Future<ConsultationEntity> call(int consultationId) {
    return _repository.getConsultation(consultationId);
  }
}

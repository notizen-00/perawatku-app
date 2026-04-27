import '../entities/consultation_message_entity.dart';
import '../repositories/consultation_repository.dart';

class SendConsultationMessageUseCase {
  SendConsultationMessageUseCase(this._repository);

  final ConsultationRepository _repository;

  Future<ConsultationMessageEntity> call({
    required int consultationId,
    required String message,
  }) {
    return _repository.addMessage(
      consultationId: consultationId,
      message: message,
    );
  }
}

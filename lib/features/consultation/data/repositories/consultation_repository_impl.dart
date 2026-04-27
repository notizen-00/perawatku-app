import '../../domain/entities/consultation_entity.dart';
import '../../domain/entities/consultation_message_entity.dart';
import '../../domain/entities/consultation_payment_entity.dart';
import '../../domain/repositories/consultation_repository.dart';
import '../datasources/consultation_remote_data_source.dart';

class ConsultationRepositoryImpl implements ConsultationRepository {
  ConsultationRepositoryImpl({
    required ConsultationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ConsultationRemoteDataSource _remoteDataSource;

  @override
  Future<ConsultationEntity> createConsultation({
    required int partnerUserId,
    required String serviceType,
    required String paymentMethod,
  }) {
    return _remoteDataSource.createConsultation(
      partnerUserId: partnerUserId,
      serviceType: serviceType,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<ConsultationEntity> getConsultation(int consultationId) {
    return _remoteDataSource.getConsultation(consultationId);
  }

  @override
  Future<ConsultationPaymentEntity> payConsultation(int consultationId) {
    return _remoteDataSource.payConsultation(consultationId);
  }

  @override
  Future<ConsultationMessageEntity> addMessage({
    required int consultationId,
    required String message,
  }) {
    return _remoteDataSource.addMessage(
      consultationId: consultationId,
      message: message,
    );
  }
}

import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/consultation_message_model.dart';
import '../models/consultation_model.dart';
import '../models/consultation_payment_model.dart';

abstract class ConsultationRemoteDataSource {
  Future<ConsultationModel> createConsultation({
    required int partnerUserId,
    required String serviceType,
    required String paymentMethod,
  });

  Future<ConsultationModel> getConsultation(int consultationId);

  Future<ConsultationPaymentModel> payConsultation(int consultationId);

  Future<ConsultationMessageModel> addMessage({
    required int consultationId,
    required String message,
  });
}

class ConsultationRemoteDataSourceImpl implements ConsultationRemoteDataSource {
  ConsultationRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<ConsultationModel> createConsultation({
    required int partnerUserId,
    required String serviceType,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.patientConsultations,
      data: {
        'partner_user_id': partnerUserId,
        'service_type': serviceType,
        'payment_method': paymentMethod,
      },
    );

    return ConsultationModel.fromJson(_extractResource(response));
  }

  @override
  Future<ConsultationModel> getConsultation(int consultationId) async {
    final response = await _apiClient.get(
      '${AppEndpoints.patientConsultations}/$consultationId',
    );

    return ConsultationModel.fromJson(_extractResource(response));
  }

  @override
  Future<ConsultationPaymentModel> payConsultation(int consultationId) async {
    final response = await _apiClient.patch(
      '${AppEndpoints.patientConsultations}/$consultationId/pay',
    );

    return ConsultationPaymentModel.fromJson(_extractResource(response));
  }

  @override
  Future<ConsultationMessageModel> addMessage({
    required int consultationId,
    required String message,
  }) async {
    final response = await _apiClient.post(
      '${AppEndpoints.patientConsultations}/$consultationId/messages',
      data: {
        'message': message,
      },
    );

    final resource = _extractResource(response);
    final nestedMessage = resource['message'];

    if (nestedMessage is Map<String, dynamic>) {
      return ConsultationMessageModel.fromJson(nestedMessage);
    }

    return ConsultationMessageModel.fromJson(resource);
  }

  Map<String, dynamic> _extractResource(Map<String, dynamic> response) {
    final directData = response['data'];
    if (directData is Map<String, dynamic>) {
      return directData;
    }

    final consultation = response['consultation'];
    if (consultation is Map<String, dynamic>) {
      return consultation;
    }

    return response;
  }
}

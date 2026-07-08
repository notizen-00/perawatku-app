import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/response_extractors.dart';
import '../../domain/entities/patient_member_payload.dart';
import '../models/patient_member_model.dart';

abstract class PatientMemberRemoteDataSource {
  Future<List<PatientMemberModel>> getMembers({
    String? relationship,
    String? search,
    int? perPage,
  });

  Future<PatientMemberModel> getMember(int memberId);

  Future<PatientMemberModel> createMember(PatientMemberPayload payload);

  Future<PatientMemberModel> updateMember(
    int memberId,
    PatientMemberPayload payload,
  );

  Future<PatientMemberModel> setPrimary(int memberId);

  Future<void> deleteMember(int memberId);
}

class PatientMemberRemoteDataSourceImpl
    implements PatientMemberRemoteDataSource {
  PatientMemberRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<PatientMemberModel>> getMembers({
    String? relationship,
    String? search,
    int? perPage,
  }) async {
    final response = await _apiClient.get(
      AppEndpoints.patientMembers,
      queryParameters: <String, dynamic>{
        if (relationship != null && relationship.trim().isNotEmpty)
          'relationship': relationship.trim(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (perPage != null) 'per_page': perPage,
      },
    );

    final items = extractLaravelPaginatedList(response);
    return items.map(PatientMemberModel.fromJson).toList();
  }

  @override
  Future<PatientMemberModel> getMember(int memberId) async {
    final response = await _apiClient.get(
      '${AppEndpoints.patientMembers}/$memberId',
    );

    return PatientMemberModel.fromJson(response);
  }

  @override
  Future<PatientMemberModel> createMember(PatientMemberPayload payload) async {
    final response = await _apiClient.post(
      AppEndpoints.patientMembers,
      data: payload.toJson(),
    );

    return PatientMemberModel.fromJson(response);
  }

  @override
  Future<PatientMemberModel> updateMember(
    int memberId,
    PatientMemberPayload payload,
  ) async {
    final response = await _apiClient.patch(
      '${AppEndpoints.patientMembers}/$memberId',
      data: payload.toJson(),
    );

    return PatientMemberModel.fromJson(response);
  }

  @override
  Future<PatientMemberModel> setPrimary(int memberId) async {
    final response = await _apiClient.patch(
      '${AppEndpoints.patientMembers}/$memberId/primary',
    );

    return PatientMemberModel.fromJson(response);
  }

  @override
  Future<void> deleteMember(int memberId) async {
    await _apiClient.delete('${AppEndpoints.patientMembers}/$memberId');
  }
}

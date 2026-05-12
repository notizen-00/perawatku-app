import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/response_extractors.dart';
import '../models/nurse_model.dart';

abstract class NurseRemoteDataSource {
  Future<List<NurseModel>> getNurses({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    int? patientAddressId,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  });
}

class NurseRemoteDataSourceImpl implements NurseRemoteDataSource {
  NurseRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<NurseModel>> getNurses({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    int? patientAddressId,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  }) async {
    final response = await _apiClient.get(
      AppEndpoints.patientNurses,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (specialization != null && specialization.trim().isNotEmpty)
          'specialization': specialization.trim(),
        if (isAvailable != null) 'is_available': isAvailable,
        if (limit != null) 'limit': limit,
        if (patientAddressId != null) 'patient_address_id': patientAddressId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (maxDistanceKm != null) 'max_distance_km': maxDistanceKm,
      },
    );

    final items = extractListOfMaps(
      response,
      preferredKeys: const <String>['data', 'nurses'],
    );

    return items.map(NurseModel.fromJson).toList();
  }
}

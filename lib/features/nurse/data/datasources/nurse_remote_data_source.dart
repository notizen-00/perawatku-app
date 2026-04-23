import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
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

    return _extractItems(response).map(NurseModel.fromJson).toList();
  }

  List<Map<String, dynamic>> _extractItems(Map<String, dynamic> response) {
    final directData = response['data'];
    if (directData is List) {
      return directData.whereType<Map<String, dynamic>>().toList();
    }

    if (directData is Map<String, dynamic>) {
      final nestedData = directData['data'];
      if (nestedData is List) {
        return nestedData.whereType<Map<String, dynamic>>().toList();
      }
    }

    final nurses = response['nurses'];
    if (nurses is List) {
      return nurses.whereType<Map<String, dynamic>>().toList();
    }

    return <Map<String, dynamic>>[];
  }
}

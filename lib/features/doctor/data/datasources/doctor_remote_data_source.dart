import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/response_extractors.dart';
import '../models/doctor_model.dart';

abstract class DoctorRemoteDataSource {
  Future<List<DoctorModel>> getDoctors({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  });
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  DoctorRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<DoctorModel>> getDoctors({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  }) async {
    final response = await _apiClient.get(
      AppEndpoints.patientDoctors,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (specialization != null && specialization.trim().isNotEmpty)
          'specialization': specialization.trim(),
        if (isAvailable != null) 'is_available': isAvailable,
        if (limit != null) 'limit': limit,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        // if (maxDistanceKm != null) 'max_distance_km': maxDistanceKm,
      },
    );

    final items = extractLaravelPaginatedList(response);

    return items.map(DoctorModel.fromJson).toList();
  }
}

import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_data_source.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl({
    required DoctorRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final DoctorRemoteDataSource _remoteDataSource;

  @override
  Future<List<DoctorEntity>> getDoctors({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  }) {
    return _remoteDataSource.getDoctors(
      search: search,
      specialization: specialization,
      isAvailable: isAvailable,
      limit: limit,
      latitude: latitude,
      longitude: longitude,
      maxDistanceKm: maxDistanceKm,
    );
  }
}

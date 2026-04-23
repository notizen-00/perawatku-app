import '../../domain/entities/nurse_entity.dart';
import '../../domain/repositories/nurse_repository.dart';
import '../datasources/nurse_remote_data_source.dart';

class NurseRepositoryImpl implements NurseRepository {
  NurseRepositoryImpl({
    required NurseRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NurseRemoteDataSource _remoteDataSource;

  @override
  Future<List<NurseEntity>> getNurses({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    int? patientAddressId,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  }) {
    return _remoteDataSource.getNurses(
      search: search,
      specialization: specialization,
      isAvailable: isAvailable,
      limit: limit,
      patientAddressId: patientAddressId,
      latitude: latitude,
      longitude: longitude,
      maxDistanceKm: maxDistanceKm,
    );
  }
}

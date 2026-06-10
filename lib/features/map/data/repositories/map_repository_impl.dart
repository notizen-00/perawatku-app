import '../../domain/entities/partner_location.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_data_source.dart';

/// Implementasi dari MapRepository
class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remoteDataSource;

  MapRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PartnerLocation>> getPartnerLocations() async {
    final models = await remoteDataSource.getPartnerLocations();
    return models;
  }

  @override
  Future<List<PartnerLocation>> getDoctorLocations() async {
    final models = await remoteDataSource.getDoctorLocations();
    return models;
  }

  @override
  Future<List<PartnerLocation>> getNurseLocations() async {
    final models = await remoteDataSource.getNurseLocations();
    return models;
  }

  @override
  Future<List<PartnerLocation>> getNearbyPartners({
    required double userLatitude,
    required double userLongitude,
    double radiusInKm = 5.0,
  }) async {
    return await remoteDataSource.getNearbyPartners(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      radiusInKm: radiusInKm,
    );
  }
}

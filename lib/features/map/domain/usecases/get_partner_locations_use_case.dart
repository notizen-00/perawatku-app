import '../entities/partner_location.dart';
import '../repositories/map_repository.dart';

/// Use case untuk mendapatkan semua lokasi mitra
class GetPartnerLocationsUseCase {
  final MapRepository repository;

  GetPartnerLocationsUseCase(this.repository);

  Future<List<PartnerLocation>> execute() {
    return repository.getPartnerLocations();
  }
}

/// Use case untuk mendapatkan lokasi dokter
class GetDoctorLocationsUseCase {
  final MapRepository repository;

  GetDoctorLocationsUseCase(this.repository);

  Future<List<PartnerLocation>> execute() {
    return repository.getDoctorLocations();
  }
}

/// Use case untuk mendapatkan lokasi perawat
class GetNurseLocationsUseCase {
  final MapRepository repository;

  GetNurseLocationsUseCase(this.repository);

  Future<List<PartnerLocation>> execute() {
    return repository.getNurseLocations();
  }
}

/// Use case untuk mendapatkan mitra terdekat
class GetNearbyPartnersUseCase {
  final MapRepository repository;

  GetNearbyPartnersUseCase(this.repository);

  Future<List<PartnerLocation>> execute({
    required double userLatitude,
    required double userLongitude,
    double radiusInKm = 5.0,
  }) {
    return repository.getNearbyPartners(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      radiusInKm: radiusInKm,
    );
  }
}

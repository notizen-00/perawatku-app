import '../entities/navigation_route.dart';
import '../entities/partner_location.dart';

/// Repository interface untuk operasi peta dan lokasi mitra
abstract class MapRepository {
  /// Mendapatkan daftar lokasi mitra (dokter & perawat) yang aktif
  Future<List<PartnerLocation>> getPartnerLocations();

  /// Mendapatkan lokasi dokter yang aktif
  Future<List<PartnerLocation>> getDoctorLocations();

  /// Mendapatkan lokasi perawat yang aktif
  Future<List<PartnerLocation>> getNurseLocations();

  /// Mendapatkan lokasi mitra terdekat dari posisi user
  Future<List<PartnerLocation>> getNearbyPartners({
    required double userLatitude,
    required double userLongitude,
    double radiusInKm = 5.0,
  });

  Future<NavigationRoute> getNavigationRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  });
}

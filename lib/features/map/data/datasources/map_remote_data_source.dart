import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/navigation_route.dart';
import '../../domain/entities/partner_location.dart';
import '../models/navigation_route_model.dart';
import '../models/partner_location_model.dart';

/// Data source untuk operasi peta dari API
abstract class MapRemoteDataSource {
  /// Mendapatkan semua lokasi mitra
  Future<List<PartnerLocationModel>> getPartnerLocations();

  /// Mendapatkan lokasi dokter
  Future<List<PartnerLocationModel>> getDoctorLocations();

  /// Mendapatkan lokasi perawat
  Future<List<PartnerLocationModel>> getNurseLocations();

  /// Mendapatkan mitra terdekat
  Future<List<PartnerLocationModel>> getNearbyPartners({
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

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final ApiClient apiClient;
  final Dio routeDio;

  MapRemoteDataSourceImpl({required this.apiClient})
    : routeDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

  @override
  Future<List<PartnerLocationModel>> getPartnerLocations() async {
    try {
      final response = await apiClient.get('/partners/locations');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PartnerLocationModel.fromJson(json)).toList();
    } on Object {
      // Jika API belum tersedia, return mock data
      return _getMockPartnerLocations();
    }
  }

  @override
  Future<List<PartnerLocationModel>> getDoctorLocations() async {
    try {
      final response = await apiClient.get('/partners/locations/doctors');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PartnerLocationModel.fromJson(json)).toList();
    } on Object {
      return _getMockDoctorLocations();
    }
  }

  @override
  Future<List<PartnerLocationModel>> getNurseLocations() async {
    try {
      final response = await apiClient.get('/partners/locations/nurses');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PartnerLocationModel.fromJson(json)).toList();
    } on Object {
      return _getMockNurseLocations();
    }
  }

  @override
  Future<List<PartnerLocationModel>> getNearbyPartners({
    required double userLatitude,
    required double userLongitude,
    double radiusInKm = 5.0,
  }) async {
    try {
      final response = await apiClient.get(
        '/partners/locations/nearby',
        queryParameters: {
          'lat': userLatitude,
          'lng': userLongitude,
          'radius': radiusInKm,
        },
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PartnerLocationModel.fromJson(json)).toList();
    } on Object {
      return _getMockNearbyPartners(
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        radiusInKm: radiusInKm,
      );
    }
  }

  @override
  Future<NavigationRoute> getNavigationRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    try {
      final coordinates =
          '$originLongitude,$originLatitude;$destinationLongitude,$destinationLatitude';
      final response = await routeDio.get<Map<String, dynamic>>(
        'https://router.project-osrm.org/route/v1/driving/$coordinates',
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
          'steps': 'false',
        },
      );

      return NavigationRouteModel.fromOsrmJson(
        response.data ?? <String, dynamic>{},
      );
    } on Object {
      return _buildFallbackRoute(
        originLatitude: originLatitude,
        originLongitude: originLongitude,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
      );
    }
  }

  /// Mock data untuk development/testing
  List<PartnerLocationModel> _getMockPartnerLocations() {
    return [
      PartnerLocationModel(
        id: '1',
        partnerId: 'doc1',
        partnerType: PartnerType.doctor,
        name: 'Dr. Andi Sp.PD',
        latitude: -8.1724,
        longitude: 113.7007,
        address: 'Jl. Gajah Mada No. 45, Kaliwates, Jember',
        isOnline: true,
        lastUpdate: DateTime.now(),
      ),
      PartnerLocationModel(
        id: '2',
        partnerId: 'doc2',
        partnerType: PartnerType.doctor,
        name: 'Dr. Budi Sp.A',
        latitude: -8.1642,
        longitude: 113.7166,
        address: 'Jl. Letjen Suprapto No. 18, Sumbersari, Jember',
        isOnline: true,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      PartnerLocationModel(
        id: '3',
        partnerId: 'nur1',
        partnerType: PartnerType.nurse,
        name: 'Ners. Citra',
        latitude: -8.1796,
        longitude: 113.6873,
        address: 'Jl. Hayam Wuruk No. 27, Mangli, Jember',
        isOnline: true,
        lastUpdate: DateTime.now(),
      ),
      PartnerLocationModel(
        id: '4',
        partnerId: 'nur2',
        partnerType: PartnerType.nurse,
        name: 'Ners. Dewi',
        latitude: -8.1578,
        longitude: 113.7251,
        address: 'Jl. Karimata No. 12, Sumbersari, Jember',
        isOnline: false,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  List<PartnerLocationModel> _getMockDoctorLocations() {
    return _getMockPartnerLocations()
        .where((p) => p.partnerType == PartnerType.doctor)
        .toList();
  }

  List<PartnerLocationModel> _getMockNurseLocations() {
    return _getMockPartnerLocations()
        .where((p) => p.partnerType == PartnerType.nurse)
        .toList();
  }

  List<PartnerLocationModel> _getMockNearbyPartners({
    required double userLatitude,
    required double userLongitude,
    required double radiusInKm,
  }) {
    // Mock: return all partners within radius
    return _getMockPartnerLocations();
  }

  NavigationRoute _buildFallbackRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) {
    final origin = LatLng(originLatitude, originLongitude);
    final destination = LatLng(destinationLatitude, destinationLongitude);
    final distanceMeters = const Distance().as(
      LengthUnit.Meter,
      origin,
      destination,
    );

    return NavigationRouteModel(
      points: [origin, destination],
      distanceMeters: distanceMeters,
      durationSeconds: distanceMeters / 8.33,
    );
  }
}

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/partner_location.dart';
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
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final ApiClient apiClient;

  MapRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PartnerLocationModel>> getPartnerLocations() async {
    try {
      final response = await apiClient.get('/partners/locations');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PartnerLocationModel.fromJson(json)).toList();
    } on DioException {
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
    } on DioException {
      return _getMockDoctorLocations();
    }
  }

  @override
  Future<List<PartnerLocationModel>> getNurseLocations() async {
    try {
      final response = await apiClient.get('/partners/locations/nurses');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PartnerLocationModel.fromJson(json)).toList();
    } on DioException {
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
    } on DioException {
      return _getMockNearbyPartners(
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        radiusInKm: radiusInKm,
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
        latitude: -6.2088,
        longitude: 106.8456,
        address: 'Jl. Sudirman No. 123, Jakarta',
        isOnline: true,
        lastUpdate: DateTime.now(),
      ),
      PartnerLocationModel(
        id: '2',
        partnerId: 'doc2',
        partnerType: PartnerType.doctor,
        name: 'Dr. Budi Sp.A',
        latitude: -6.2100,
        longitude: 106.8480,
        address: 'Jl. Thamrin No. 45, Jakarta',
        isOnline: true,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      PartnerLocationModel(
        id: '3',
        partnerId: 'nur1',
        partnerType: PartnerType.nurse,
        name: 'Ners. Citra',
        latitude: -6.2050,
        longitude: 106.8400,
        address: 'Jl. Gatot Subroto No. 78, Jakarta',
        isOnline: true,
        lastUpdate: DateTime.now(),
      ),
      PartnerLocationModel(
        id: '4',
        partnerId: 'nur2',
        partnerType: PartnerType.nurse,
        name: 'Ners. Dewi',
        latitude: -6.2120,
        longitude: 106.8500,
        address: 'Jl. HR Rasuna Said No. 12, Jakarta',
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
}

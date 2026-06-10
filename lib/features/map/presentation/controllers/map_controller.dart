import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/partner_location.dart';
import '../../domain/usecases/get_partner_locations_use_case.dart';

/// Controller untuk mengelola state peta dan lokasi mitra
class MapController extends GetxController {
  final GetPartnerLocationsUseCase getPartnerLocationsUseCase;

  MapController(this.getPartnerLocationsUseCase);

  // Observable state
  final RxList<PartnerLocation> partnerLocations = <PartnerLocation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<LatLng> currentLocation = const LatLng(
    -6.2088,
    106.8456,
  ).obs; // Default Jakarta
  final RxBool isTrackingLocation = false.obs;
  final Rx<PartnerType?> filterType = Rx<PartnerType?>(null); // null = all

  // Map center position (for UI state, not for MapController)
  final mapCenter = const LatLng(-6.2088, 106.8456).obs;
  final mapZoom = 13.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPartnerLocations();
    getCurrentLocation();
  }

  /// Load semua lokasi mitra
  Future<void> loadPartnerLocations() async {
    try {
      isLoading(true);
      errorMessage('');
      final locations = await getPartnerLocationsUseCase.execute();
      partnerLocations.assignAll(locations);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', 'Gagal memuat lokasi mitra');
    } finally {
      isLoading(false);
    }
  }

  /// Mendapatkan lokasi user saat ini
  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Izin Ditolak',
            'Izin lokasi diperlukan untuk fitur ini',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin Ditolak',
          'Aktifkan izin lokasi di pengaturan untuk menggunakan fitur ini',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      mapCenter.value = currentLocation.value;
      mapZoom.value = 13;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi Anda');
    }
  }

  /// Filter lokasi berdasarkan tipe mitra
  List<PartnerLocation> get filteredLocations {
    if (filterType.value == null) {
      return partnerLocations;
    }
    return partnerLocations
        .where((loc) => loc.partnerType == filterType.value)
        .toList();
  }

  /// Set filter tipe mitra
  void setFilter(PartnerType? type) {
    filterType.value = type;
  }

  /// Toggle filter
  void toggleFilter(PartnerType type) {
    if (filterType.value == type) {
      filterType.value = null;
    } else {
      filterType.value = type;
    }
  }

  /// Pindah ke lokasi mitra
  void moveToLocation(LatLng location, {double? zoom}) {
    mapCenter.value = location;
    mapZoom.value = zoom ?? 15;
  }

  /// Pindah ke lokasi user
  void moveToUserLocation() {
    moveToLocation(currentLocation.value);
  }

  /// Refresh data
  Future<void> refresh() async {
    await getCurrentLocation();
    await loadPartnerLocations();
  }

  /// Hitung jarak antara dua titik (dalam km)
  double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        ) /
        1000; // Convert to km
  }

  /// Dapatkan mitra terdekat
  List<PartnerLocation> getNearestPartners({int count = 5}) {
    final sorted = List<PartnerLocation>.from(partnerLocations);
    sorted.sort((a, b) {
      final distA = calculateDistance(
        currentLocation.value,
        LatLng(a.latitude, a.longitude),
      );
      final distB = calculateDistance(
        currentLocation.value,
        LatLng(b.latitude, b.longitude),
      );
      return distA.compareTo(distB);
    });
    return sorted.take(count).toList();
  }
}

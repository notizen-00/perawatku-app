import 'dart:async';

import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/navigation_route.dart';
import '../../domain/entities/partner_location.dart';
import '../../domain/usecases/get_partner_locations_use_case.dart';

/// Controller untuk mengelola state peta dan lokasi mitra
class MapController extends GetxController {
  final GetPartnerLocationsUseCase getPartnerLocationsUseCase;
  final GetNavigationRouteUseCase getNavigationRouteUseCase;

  MapController(
    this.getPartnerLocationsUseCase,
    this.getNavigationRouteUseCase,
  );

  final flutter_map.MapController flutterMapController =
      flutter_map.MapController();

  // Observable state
  final RxList<PartnerLocation> partnerLocations = <PartnerLocation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<LatLng> currentLocation = const LatLng(
    -8.1724,
    113.7007,
  ).obs; // Default Jember
  final RxBool isTrackingLocation = false.obs;
  final Rx<PartnerType?> filterType = Rx<PartnerType?>(null); // null = all
  final Rx<PartnerLocation?> selectedPartner = Rx<PartnerLocation?>(null);
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isRouteLoading = false.obs;
  final RxDouble routeDistanceMeters = 0.0.obs;
  final RxDouble routeDurationSeconds = 0.0.obs;
  final RxDouble initialRouteDistanceMeters = 0.0.obs;
  Timer? _trackingTimer;

  // Map center position - menggunakan geolocator langsung
  final mapCenter = LatLng(
    -8.1724,
    113.7007,
  ).obs; // Default Jember, akan diupdate dengan geolocator
  final mapZoom = 7.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPartnerLocations();
    getCurrentLocation();
  }

  @override
  void onClose() {
    _trackingTimer?.cancel();
    flutterMapController.dispose();
    super.onClose();
  }

  /// Load semua lokasi mitra
  Future<void> loadPartnerLocations() async {
    try {
      isLoading(true);
      errorMessage('');
      final locations = await getPartnerLocationsUseCase.execute();
      partnerLocations.assignAll(locations);
      _syncSelectedPartner();
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', 'Gagal memuat lokasi mitra');
    } finally {
      isLoading(false);
    }
  }

  /// Mendapatkan lokasi user saat ini menggunakan geolocator langsung
  Future<void> getCurrentLocation() async {
    try {
      // Cek dan minta izin lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Lokasi Tidak Aktif',
          'Aktifkan layanan lokasi di perangkat Anda',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin Ditolak',
          'Aktifkan izin lokasi di pengaturan untuk menggunakan fitur ini',
        );
        return;
      }

      // Dapatkan posisi langsung dari geolocator
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      // Update map center menggunakan geolocator langsung
      mapCenter.value = LatLng(position.latitude, position.longitude);
      mapZoom.value = 15; // Zoom lebih dekat untuk melihat lokasi user
      _moveFlutterMap(mapCenter.value, mapZoom.value);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi Anda');
    }
  }

  /// Update map center ke lokasi user menggunakan geolocator langsung
  Future<void> centerMapOnUser() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Lokasi Tidak Aktif',
          'Aktifkan layanan lokasi di perangkat Anda',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin Ditolak',
          'Aktifkan izin lokasi di pengaturan untuk menggunakan fitur ini',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = LatLng(position.latitude, position.longitude);
      mapCenter.value = location;
      mapZoom.value = 15;
      _moveFlutterMap(location, mapZoom.value);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memusatkan peta pada lokasi Anda');
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
    _moveFlutterMap(location, mapZoom.value);
  }

  /// Pindah ke lokasi user
  void moveToUserLocation() {
    moveToLocation(currentLocation.value);
  }

  /// Refresh data
  Future<void> refresh() async {
    await getCurrentLocation();
    await loadPartnerLocations();
    if (selectedPartner.value != null) {
      await refreshNavigationRoute(showLoading: false);
    }
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

  Future<void> startNavigation(PartnerLocation partner) async {
    selectedPartner.value = partner;
    initialRouteDistanceMeters.value = 0;
    isTrackingLocation.value = true;
    await refreshNavigationRoute();
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await loadPartnerLocations();
      await refreshNavigationRoute(showLoading: false);
    });
  }

  Future<void> refreshNavigationRoute({bool showLoading = true}) async {
    final partner = selectedPartner.value;
    if (partner == null) {
      return;
    }

    try {
      if (showLoading) {
        isRouteLoading(true);
      }

      final route = await getNavigationRouteUseCase.execute(
        originLatitude: partner.latitude,
        originLongitude: partner.longitude,
        destinationLatitude: currentLocation.value.latitude,
        destinationLongitude: currentLocation.value.longitude,
      );

      _applyNavigationRoute(route);
      _fitNavigationBounds(partner);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat rute navigasi');
    } finally {
      if (showLoading) {
        isRouteLoading(false);
      }
    }
  }

  void stopNavigation() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    selectedPartner.value = null;
    routePoints.clear();
    routeDistanceMeters.value = 0;
    routeDurationSeconds.value = 0;
    initialRouteDistanceMeters.value = 0;
    isTrackingLocation.value = false;
  }

  String get etaLabel {
    final seconds = routeDurationSeconds.value.round();
    if (seconds <= 0) {
      return '-';
    }

    final minutes = (seconds / 60).ceil();
    if (minutes < 60) {
      return '$minutes menit';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours jam';
    }

    return '$hours jam $remainingMinutes menit';
  }

  String get routeDistanceLabel {
    final meters = routeDistanceMeters.value;
    if (meters <= 0) {
      return '-';
    }

    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }

    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  double get partnerProgress {
    final initialDistance = initialRouteDistanceMeters.value;
    if (initialDistance <= 0 || routeDistanceMeters.value <= 0) {
      return 0;
    }

    final progress =
        (initialDistance - routeDistanceMeters.value) / initialDistance;
    return progress.clamp(0.0, 1.0).toDouble();
  }

  String get lastPartnerUpdateLabel {
    final updatedAt = selectedPartner.value?.lastUpdate;
    if (updatedAt == null) {
      return 'Belum ada update';
    }

    final diff = DateTime.now().difference(updatedAt);
    if (diff.inMinutes < 1) {
      return 'Baru saja';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} menit lalu';
    }
    return '${diff.inHours} jam lalu';
  }

  void _applyNavigationRoute(NavigationRoute route) {
    routePoints.assignAll(route.points);
    routeDistanceMeters.value = route.distanceMeters;
    routeDurationSeconds.value = route.durationSeconds;
    if (initialRouteDistanceMeters.value <= 0 && route.distanceMeters > 0) {
      initialRouteDistanceMeters.value = route.distanceMeters;
    }
  }

  void _syncSelectedPartner() {
    final partner = selectedPartner.value;
    if (partner == null) {
      return;
    }

    final matches = partnerLocations.where((item) => item.id == partner.id);
    if (matches.isNotEmpty) {
      selectedPartner.value = matches.first;
    }
  }

  void _fitNavigationBounds(PartnerLocation partner) {
    final partnerPoint = LatLng(partner.latitude, partner.longitude);
    final userPoint = currentLocation.value;
    final center = LatLng(
      (partnerPoint.latitude + userPoint.latitude) / 2,
      (partnerPoint.longitude + userPoint.longitude) / 2,
    );
    moveToLocation(center, zoom: _zoomForDistance(routeDistanceMeters.value));
  }

  double _zoomForDistance(double meters) {
    if (meters < 1000) {
      return 15.5;
    }
    if (meters < 3000) {
      return 14;
    }
    if (meters < 8000) {
      return 13;
    }
    return 11.5;
  }

  void _moveFlutterMap(LatLng location, double zoom) {
    try {
      flutterMapController.move(location, zoom);
    } catch (_) {
      // Map belum siap saat controller melakukan init awal.
    }
  }
}

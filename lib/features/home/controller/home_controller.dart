import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../nurse/domain/entities/nurse_entity.dart';
import '../../nurse/domain/usecases/get_nurses_use_case.dart';

class HomeController extends GetxController {
  HomeController(this._getNursesUseCase);

  final GetNursesUseCase _getNursesUseCase;

  final RxInt selectedBottomNavIndex = 0.obs;
  final Rx<LocationBannerState> locationState =
      const LocationBannerState.loading().obs;
  final RxList<NurseEntity> nearbyNurses = <NurseEntity>[].obs;
  final RxBool isLoadingNurses = false.obs;
  final RxnString nurseErrorMessage = RxnString();

  Position? _currentPosition;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentLocation();
  }

  void selectBottomNav(int index) {
    selectedBottomNavIndex.value = index;
  }

  Future<void> fetchCurrentLocation() async {
    locationState.value = const LocationBannerState.loading();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationState.value = const LocationBannerState.error(
          title: 'Layanan lokasi nonaktif',
          subtitle: 'Aktifkan GPS untuk melihat lokasi saat ini.',
          actionLabel: 'Nyalakan GPS',
        );
        await fetchNearbyNurses();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        locationState.value = const LocationBannerState.error(
          title: 'Izin lokasi ditolak',
          subtitle: 'Berikan izin lokasi untuk menampilkan posisi Anda.',
          actionLabel: 'Izinkan lokasi',
        );
        await fetchNearbyNurses();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        locationState.value = const LocationBannerState.error(
          title: 'Izin lokasi diblokir',
          subtitle:
              'Aktifkan kembali izin lokasi dari pengaturan perangkat Anda.',
          actionLabel: 'Buka pengaturan',
        );
        await fetchNearbyNurses();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final position = _currentPosition!;

      String title = 'Lokasi saat ini';
      String subtitle =
          '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          title = _joinLocationParts([
            placemark.subLocality,
            placemark.locality,
          ]);
          subtitle = _joinLocationParts([
            placemark.street,
            placemark.subAdministrativeArea,
            placemark.administrativeArea,
          ]);
        }
      } catch (_) {
        // Fallback ke koordinat jika reverse geocoding gagal.
      }

      locationState.value = LocationBannerState.ready(
        title: title.isEmpty ? 'Lokasi saat ini' : title,
        subtitle: subtitle.isEmpty
            ? '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}'
            : subtitle,
        actionLabel: 'Perbarui lokasi',
      );
      await fetchNearbyNurses(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      locationState.value = const LocationBannerState.error(
        title: 'Lokasi belum tersedia',
        subtitle: 'Coba lagi beberapa saat lagi untuk memuat lokasi real Anda.',
        actionLabel: 'Coba lagi',
      );
      await fetchNearbyNurses();
    }
  }

  Future<void> fetchNearbyNurses({
    String? search,
    String? specialization,
    bool? isAvailable,
    int limit = 5,
    double? latitude,
    double? longitude,
    double? maxDistanceKm = 25,
  }) async {
    isLoadingNurses.value = true;
    nurseErrorMessage.value = null;

    try {
      final effectiveLatitude = latitude ?? _currentPosition?.latitude;
      final effectiveLongitude = longitude ?? _currentPosition?.longitude;

      final nurses = await _getNursesUseCase(
        search: search,
        specialization: specialization,
        isAvailable: isAvailable,
        limit: limit,
        latitude: effectiveLatitude,
        longitude: effectiveLongitude,
        maxDistanceKm: maxDistanceKm,
      );

      nearbyNurses.assignAll(nurses);
    } on AppException catch (error) {
      nearbyNurses.clear();
      nurseErrorMessage.value = error.message;
    } catch (_) {
      nearbyNurses.clear();
      nurseErrorMessage.value = 'Gagal memuat daftar perawat.';
    } finally {
      isLoadingNurses.value = false;
    }
  }

  String _joinLocationParts(List<String?> parts) {
    return parts
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toSet()
        .join(', ');
  }
}

class LocationBannerState {
  const LocationBannerState({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.isLoading,
    required this.hasError,
  });

  const LocationBannerState.loading()
      : title = 'Mengambil lokasi real...',
        subtitle = 'Mohon tunggu, kami sedang membaca posisi perangkat Anda.',
        actionLabel = 'Memuat',
        isLoading = true,
        hasError = false;

  const LocationBannerState.ready({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  })  : isLoading = false,
        hasError = false;

  const LocationBannerState.error({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  })  : isLoading = false,
        hasError = true;

  final String title;
  final String subtitle;
  final String actionLabel;
  final bool isLoading;
  final bool hasError;
}

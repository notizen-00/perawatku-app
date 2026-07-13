import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/routes/app_routes.dart';
import '../../nurse/domain/entities/nurse_entity.dart';
import '../../nurse/domain/usecases/get_nurses_use_case.dart';
import '../../service_booking/domain/entities/service_booking_service_entity.dart';
import '../../service_booking/domain/usecases/get_service_booking_services_use_case.dart';
import '../../service_booking/presentation/controllers/service_booking_controller.dart';

class HomeController extends GetxController {
  HomeController({
    required GetNursesUseCase getNursesUseCase,
    required GetServiceBookingServicesUseCase getServicesUseCase,
  }) : _getNursesUseCase = getNursesUseCase,
       _getServicesUseCase = getServicesUseCase;

  final GetNursesUseCase _getNursesUseCase;
  final GetServiceBookingServicesUseCase _getServicesUseCase;

  final RxInt selectedBottomNavIndex = 0.obs;
  final Rx<LocationBannerState> locationState =
      const LocationBannerState.loading().obs;
  final RxList<NurseEntity> nearbyNurses = <NurseEntity>[].obs;
  final RxList<ServiceBookingServiceEntity> serviceCatalog =
      <ServiceBookingServiceEntity>[].obs;
  final RxBool isLoadingNurses = false.obs;
  final RxBool isLoadingServices = false.obs;
  final RxnString nurseErrorMessage = RxnString();
  final RxnString serviceErrorMessage = RxnString();
  final RxnString selectedServiceCategoryKey = RxnString();
  final RxnInt requestedMatchmakingServiceId = RxnInt();

  Position? _currentPosition;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentLocation();
    fetchServiceCatalog();
  }

  void selectBottomNav(int index) {
    selectedBottomNavIndex.value = index;
  }

  Future<void> refreshHome() async {
    await Future.wait([
      fetchCurrentLocation(),
      fetchServiceCatalog(),
    ]);
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

  Future<void> fetchServiceCatalog() async {
    isLoadingServices.value = true;
    serviceErrorMessage.value = null;

    try {
      final services = await _getServicesUseCase(perPage: 100);
      serviceCatalog.assignAll(services);

      if (selectedServiceCategoryKey.value == null &&
          groupedServices.isNotEmpty) {
        selectedServiceCategoryKey.value = groupedServices.first.key;
      }
    } on AppException catch (error) {
      serviceCatalog.clear();
      serviceErrorMessage.value = error.message;
    } catch (_) {
      serviceCatalog.clear();
      serviceErrorMessage.value = 'Gagal memuat katalog layanan.';
    } finally {
      isLoadingServices.value = false;
    }
  }

  List<ServiceCategoryGroup> get groupedServices {
    final groups = <String, ServiceCategoryGroup>{};

    for (final service in serviceCatalog) {
      final categoryName =
          (service.categoryName ?? service.category ?? 'Lainnya').trim();
      final label = categoryName.isEmpty ? 'Lainnya' : categoryName;
      final key = service.categoryId?.toString() ?? label.toLowerCase();
      final current = groups[key];

      if (current == null) {
        groups[key] = ServiceCategoryGroup(
          key: key,
          id: service.categoryId,
          name: label,
          icon: service.categoryIcon,
          services: <ServiceBookingServiceEntity>[service],
        );
      } else {
        current.services.add(service);
      }
    }

    final result = groups.values.toList();
    result.sort((first, second) => first.name.compareTo(second.name));
    return result;
  }

  ServiceCategoryGroup? get selectedServiceCategory {
    final groups = groupedServices;
    if (groups.isEmpty) {
      return null;
    }

    final selectedKey = selectedServiceCategoryKey.value;
    for (final group in groups) {
      if (group.key == selectedKey) {
        return group;
      }
    }

    return groups.first;
  }

  void selectServiceCategory(ServiceCategoryGroup group) {
    selectedServiceCategoryKey.value = group.key;
  }

  void openMatchmakingForService(ServiceBookingServiceEntity service) {
    proceedWithServiceBooking(service);
  }

  void proceedWithServiceBooking(ServiceBookingServiceEntity service) {
    if (_isDoctorConsultationService(service)) {
      Get.toNamed(AppRoutes.doctors);
      return;
    }

    requestedMatchmakingServiceId.value = service.bookingServiceId;
    if (Get.isRegistered<ServiceBookingController>()) {
      Get.find<ServiceBookingController>().primeSelectedService(service);
    }
    Get.toNamed(AppRoutes.serviceBookingCheckout, arguments: service);
  }

  bool _isDoctorConsultationService(ServiceBookingServiceEntity service) {
    final haystack = [
      service.name,
      service.category,
      service.categoryName,
      service.serviceType,
      service.serviceMode,
    ].whereType<String>().join(' ').toLowerCase();

    final isDoctor =
        haystack.contains('dokter') ||
        haystack.contains('doctor') ||
        haystack.contains('konsultasi') ||
        haystack.contains('consultation');
    final isVisitHomecare =
        haystack.contains('homecare') ||
        haystack.contains('home care') ||
        haystack.contains('visit');

    return isDoctor && !isVisitHomecare;
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

class ServiceCategoryGroup {
  ServiceCategoryGroup({
    required this.key,
    required this.id,
    required this.name,
    required this.icon,
    required this.services,
  });

  final String key;
  final int? id;
  final String name;
  final String? icon;
  final List<ServiceBookingServiceEntity> services;
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
  }) : isLoading = false,
       hasError = false;

  const LocationBannerState.error({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  }) : isLoading = false,
       hasError = true;

  final String title;
  final String subtitle;
  final String actionLabel;
  final bool isLoading;
  final bool hasError;
}

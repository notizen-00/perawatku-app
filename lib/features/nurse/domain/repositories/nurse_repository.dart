import '../entities/nurse_entity.dart';

abstract class NurseRepository {
  Future<List<NurseEntity>> getNurses({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    int? patientAddressId,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  });
}

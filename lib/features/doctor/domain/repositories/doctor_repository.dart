import '../entities/doctor_entity.dart';

abstract class DoctorRepository {
  Future<List<DoctorEntity>> getDoctors({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  });
}

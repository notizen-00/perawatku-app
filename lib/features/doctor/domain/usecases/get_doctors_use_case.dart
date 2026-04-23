import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorsUseCase {
  GetDoctorsUseCase(this._repository);

  final DoctorRepository _repository;

  Future<List<DoctorEntity>> call({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  }) {
    return _repository.getDoctors(
      search: search,
      specialization: specialization,
      isAvailable: isAvailable,
      limit: limit,
      latitude: latitude,
      longitude: longitude,
      maxDistanceKm: maxDistanceKm,
    );
  }
}

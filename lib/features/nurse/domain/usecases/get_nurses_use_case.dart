import '../entities/nurse_entity.dart';
import '../repositories/nurse_repository.dart';

class GetNursesUseCase {
  GetNursesUseCase(this._repository);

  final NurseRepository _repository;

  Future<List<NurseEntity>> call({
    String? search,
    String? specialization,
    bool? isAvailable,
    int? limit,
    int? patientAddressId,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
  }) {
    return _repository.getNurses(
      search: search,
      specialization: specialization,
      isAvailable: isAvailable,
      limit: limit,
      patientAddressId: patientAddressId,
      latitude: latitude,
      longitude: longitude,
      maxDistanceKm: maxDistanceKm,
    );
  }
}

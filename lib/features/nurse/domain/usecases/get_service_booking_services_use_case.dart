import '../entities/service_booking_service_entity.dart';
import '../repositories/service_booking_repository.dart';

class GetServiceBookingServicesUseCase {
  GetServiceBookingServicesUseCase(this._repository);

  final ServiceBookingRepository _repository;

  Future<List<ServiceBookingServiceEntity>> call({
    String? category,
    String? search,
    int? perPage,
  }) {
    return _repository.getServices(
      category: category,
      search: search,
      perPage: perPage,
    );
  }
}

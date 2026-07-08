import '../entities/service_booking_entity.dart';
import '../repositories/service_booking_repository.dart';

class GetServiceBookingUseCase {
  GetServiceBookingUseCase(this._repository);

  final ServiceBookingRepository _repository;

  Future<ServiceBookingEntity> call(int bookingId) {
    return _repository.getBooking(bookingId);
  }
}

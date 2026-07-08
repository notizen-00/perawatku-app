import '../entities/service_booking_entity.dart';
import '../repositories/service_booking_repository.dart';

class CancelServiceBookingUseCase {
  CancelServiceBookingUseCase(this._repository);

  final ServiceBookingRepository _repository;

  Future<ServiceBookingEntity> call(int bookingId, {String? reason}) {
    return _repository.cancelBooking(bookingId, reason: reason);
  }
}

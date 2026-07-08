import '../entities/service_booking_entity.dart';
import '../repositories/service_booking_repository.dart';

class PayServiceBookingUseCase {
  PayServiceBookingUseCase(this._repository);

  final ServiceBookingRepository _repository;

  Future<ServiceBookingEntity> call(int bookingId, {String? notes}) {
    return _repository.payBooking(bookingId, notes: notes);
  }
}

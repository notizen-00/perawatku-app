import '../entities/service_booking_tracking_entity.dart';
import '../repositories/service_booking_repository.dart';

class GetServiceBookingTrackingUseCase {
  GetServiceBookingTrackingUseCase(this._repository);

  final ServiceBookingRepository _repository;

  Future<ServiceBookingTrackingEntity> call(int bookingId) {
    return _repository.getTracking(bookingId);
  }
}

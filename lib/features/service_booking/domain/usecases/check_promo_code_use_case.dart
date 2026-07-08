import '../repositories/service_booking_repository.dart';

class CheckPromoCodeUseCase {
  CheckPromoCodeUseCase(this._repository);

  final ServiceBookingRepository _repository;

  Future<Map<String, dynamic>> call({
    required String code,
    required int serviceId,
  }) {
    return _repository.checkPromoCode(code: code, serviceId: serviceId);
  }
}

import '../entities/activity_record_entity.dart';
import '../repositories/activity_repository.dart';

class GetMedicinePurchaseActivitiesUseCase {
  GetMedicinePurchaseActivitiesUseCase(this._repository);

  final ActivityRepository _repository;

  Future<List<ActivityRecordEntity>> call() {
    return _repository.getMedicinePurchaseActivities();
  }
}

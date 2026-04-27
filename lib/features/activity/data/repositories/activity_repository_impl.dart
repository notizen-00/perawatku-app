import '../../domain/entities/activity_record_entity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_remote_data_source.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl({
    required ActivityRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ActivityRemoteDataSource _remoteDataSource;

  @override
  Future<List<ActivityRecordEntity>> getConsultationActivities() {
    return _remoteDataSource.getConsultationActivities();
  }

  @override
  Future<List<ActivityRecordEntity>> getMedicinePurchaseActivities() {
    return _remoteDataSource.getMedicinePurchaseActivities();
  }

  @override
  Future<List<ActivityRecordEntity>> getOtherActivities() {
    return _remoteDataSource.getOtherActivities();
  }
}

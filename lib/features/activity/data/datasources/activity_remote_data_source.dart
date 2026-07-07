import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/activity_record_model.dart';

abstract class ActivityRemoteDataSource {
  Future<List<ActivityRecordModel>> getConsultationActivities();

  Future<List<ActivityRecordModel>> getMedicinePurchaseActivities();

  Future<List<ActivityRecordModel>> getOtherActivities();
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  ActivityRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ActivityRecordModel>> getConsultationActivities() async {
    final response = await _apiClient.get(AppEndpoints.patientConsultations);
    final items = _extractItems(response);

    return items.map(ActivityRecordModel.fromConsultationJson).toList();
  }

  @override
  Future<List<ActivityRecordModel>> getMedicinePurchaseActivities() async {
    final response = await _apiClient.get(AppEndpoints.patientOrders);
    final items = _extractItems(response);

    return items.map(ActivityRecordModel.fromOrderJson).toList();
  }

  @override
  Future<List<ActivityRecordModel>> getOtherActivities() async {
    final response = await _apiClient.get(AppEndpoints.patientServiceBookings);
    final items = _extractItems(response);

    return items.map(ActivityRecordModel.fromServiceBookingJson).toList();
  }

  List<Map<String, dynamic>> _extractItems(Map<String, dynamic> response) {
    final directData = response['data'];
    if (directData is List) {
      return directData.whereType<Map<String, dynamic>>().toList();
    }

    if (directData is Map<String, dynamic>) {
      final nestedData = directData['data'];
      if (nestedData is List) {
        return nestedData.whereType<Map<String, dynamic>>().toList();
      }
    }

    final consultations = response['consultations'];
    if (consultations is List) {
      return consultations.whereType<Map<String, dynamic>>().toList();
    }

    final orders = response['orders'];
    if (orders is List) {
      return orders.whereType<Map<String, dynamic>>().toList();
    }

    final serviceBookings = response['service_bookings'];
    if (serviceBookings is List) {
      return serviceBookings.whereType<Map<String, dynamic>>().toList();
    }

    return <Map<String, dynamic>>[];
  }
}

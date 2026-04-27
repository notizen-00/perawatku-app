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
    const mockItems = [
      {
        'id': 'RX-1001',
        'category': 'medicine',
        'title': 'Pembelian Obat Flu & Batuk',
        'subtitle': 'Apotek Mitra Sehat',
        'status': 'delivered',
        'date_time': '2026-04-24T10:30:00Z',
        'amount_label': 'Rp128.000',
        'reference': 'ORD-RX-1001',
      },
      {
        'id': 'RX-0998',
        'category': 'medicine',
        'title': 'Vitamin & Suplemen Harian',
        'subtitle': 'Apotek Medic Care',
        'status': 'processing',
        'date_time': '2026-04-20T08:15:00Z',
        'amount_label': 'Rp76.500',
        'reference': 'ORD-RX-0998',
      },
    ];

    return mockItems.map(ActivityRecordModel.fromMap).toList();
  }

  @override
  Future<List<ActivityRecordModel>> getOtherActivities() async {
    const mockItems = [
      {
        'id': 'LAB-3001',
        'category': 'other',
        'title': 'Reservasi Cek Lab',
        'subtitle': 'Paket darah lengkap',
        'status': 'scheduled',
        'date_time': '2026-04-29T07:00:00Z',
        'amount_label': 'Rp210.000',
        'reference': 'LAB-3001',
      },
      {
        'id': 'HOME-7004',
        'category': 'other',
        'title': 'Kunjungan Perawat ke Rumah',
        'subtitle': 'Perawatan luka pasca tindakan',
        'status': 'completed',
        'date_time': '2026-04-18T14:45:00Z',
        'amount_label': 'Rp185.000',
        'reference': 'HOME-7004',
      },
    ];

    return mockItems.map(ActivityRecordModel.fromMap).toList();
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

    return <Map<String, dynamic>>[];
  }
}

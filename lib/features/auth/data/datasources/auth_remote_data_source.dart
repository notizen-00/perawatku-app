import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_result_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResultModel> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<LoginResultModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.patientLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    return LoginResultModel.fromJson(response);
  }
}

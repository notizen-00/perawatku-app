import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_result_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResultModel> login({
    required String email,
    required String password,
  });

  Future<LoginResultModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? allergies,
    String? medicalNotes,
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

  @override
  Future<LoginResultModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? allergies,
    String? medicalNotes,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.patientRegister,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty)
          'date_of_birth': dateOfBirth.trim(),
        if (gender != null && gender.trim().isNotEmpty)
          'gender': gender.trim(),
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
        if (bloodType != null && bloodType.trim().isNotEmpty)
          'blood_type': bloodType.trim(),
        if (emergencyContactName != null &&
            emergencyContactName.trim().isNotEmpty)
          'emergency_contact_name': emergencyContactName.trim(),
        if (emergencyContactPhone != null &&
            emergencyContactPhone.trim().isNotEmpty)
          'emergency_contact_phone': emergencyContactPhone.trim(),
        if (allergies != null && allergies.trim().isNotEmpty)
          'allergies': allergies.trim(),
        if (medicalNotes != null && medicalNotes.trim().isNotEmpty)
          'medical_notes': medicalNotes.trim(),
      },
    );

    return LoginResultModel.fromJson(response);
  }
}

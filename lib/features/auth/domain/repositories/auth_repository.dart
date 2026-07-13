import '../entities/login_result_entity.dart';

abstract class AuthRepository {
  Future<LoginResultEntity> login({
    required String email,
    required String password,
  });

  Future<LoginResultEntity> register({
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

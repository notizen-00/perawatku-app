import '../../../../core/services/storage_service.dart';
import '../../domain/entities/login_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required StorageService storageService,
  })  : _remoteDataSource = remoteDataSource,
        _storageService = storageService;

  final AuthRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  @override
  Future<LoginResultEntity> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _storageService.saveSession(
      token: result.token,
      userJson: (result.user as AuthUserModel).toJson(),
    );

    return result;
  }

  @override
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
  }) async {
    final result = await _remoteDataSource.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      dateOfBirth: dateOfBirth,
      gender: gender,
      address: address,
      bloodType: bloodType,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      allergies: allergies,
      medicalNotes: medicalNotes,
    );

    await _storageService.saveSession(
      token: result.token,
      userJson: (result.user as AuthUserModel).toJson(),
    );

    return result;
  }
}

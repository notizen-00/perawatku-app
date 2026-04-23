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
}

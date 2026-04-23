import '../../domain/entities/login_result_entity.dart';
import 'auth_user_model.dart';

class LoginResultModel extends LoginResultEntity {
  const LoginResultModel({
    required super.message,
    required super.user,
    required super.token,
  });

  factory LoginResultModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['data'] as Map<String, dynamic>? ?? {};

    return LoginResultModel(
      message: json['message'] as String? ?? '',
      user: AuthUserModel.fromJson(userJson),
      token: json['user_api_token'] as String? ?? '',
    );
  }
}

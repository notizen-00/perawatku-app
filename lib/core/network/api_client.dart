import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../services/storage_service.dart';

class ApiClient {
  ApiClient({
    required StorageService storageService,
  })  : _storageService = storageService,
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.token;

          if (AppConfig.shouldUseNgrokHeader) {
            options.headers['ngrok-skip-browser-warning'] = 'true';
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) {
          handler.reject(error);
        },
      ),
    );
  }

  final Dio _dio;
  final StorageService _storageService;

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    final responseData = error.response?.data;
    final statusCode = error.response?.statusCode;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return AppException(message, statusCode: statusCode);
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException('Koneksi timeout. Coba lagi.', statusCode: statusCode);
      case DioExceptionType.connectionError:
        return AppException(
          'Tidak bisa terhubung ke server.',
          statusCode: statusCode,
        );
      default:
        return AppException(
          'Terjadi kesalahan pada jaringan.',
          statusCode: statusCode,
        );
    }
  }
}
